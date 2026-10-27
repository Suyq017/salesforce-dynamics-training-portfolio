Imports StudentDataCreate.WebReference
Imports System.Reflection

''' <summary>
''' Salesforce 接続 / DML ヘルパー クラス
''' </summary>
''' <remarks>
''' ログインと、insert / update / upsert / delete / query を行う。
''' DML は API 上限（200 件）ごとにバッチ分割し、一定件数ごとに Sleep する。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy
''' </remarks>
Public Class SFDCHelper

#Region "メンバ"
    Public m_Sforce As SforceService
    Private m_ClientId As String        ' Connected App の Consumer Key
    Private m_OAuthLoginUrl As String   ' ログイン URL（例：https://login.salesforce.com）
    Private m_Scope As String           ' OAuth スコープ
    Private m_ProxyHost As String       ' プロキシホスト
    Private m_ProxyPort As String       ' プロキシポート
    Private m_ProxyUser As String       ' プロキシユーザ
    Private m_ProxyPass As String       ' プロキシパスワード

    Private m_LoginUrl As String = String.Empty ' 接続先 URL（ログ出力用。instance_url）
    Public ReadOnly Property LoginUrl As String
        Get
            Return m_LoginUrl
        End Get
    End Property

    Private Const UPD_MAX_CNT As Integer = 200     ' 1 回の DML 最大件数
    Private Const m_SleepTime As Integer = 1000    ' 待機時間（ミリ秒）
    Private Const m_LoginTimeout As Integer = 10000000 ' ログインタイムアウト値（ミリ秒）
#End Region

#Region "コンストラクタ"
    ''' <summary>
    ''' コンストラクタ
    ''' </summary>
    ''' <param name="clientId">Connected App の Consumer Key</param>
    ''' <param name="loginUrl">ログイン URL</param>
    ''' <param name="scope">OAuth スコープ</param>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Sub New(ByVal clientId As String,
                   ByVal loginUrl As String,
                   ByVal scope As String,
                   ByVal proxyHost As String,
                   ByVal proxyPort As String,
                   ByVal proxyUser As String,
                   ByVal proxyPass As String)
        Me.m_ClientId = clientId
        Me.m_OAuthLoginUrl = loginUrl
        Me.m_Scope = scope
        Me.m_ProxyHost = proxyHost
        Me.m_ProxyPort = proxyPort
        Me.m_ProxyUser = proxyUser
        Me.m_ProxyPass = proxyPass
        Me.m_Sforce = New SforceService
    End Sub
#End Region

#Region "ログイン"
    ''' <summary>
    ''' ログインする。（OAuth 2.0 Device Flow）
    ''' セッションが有効な場合は再ログインしない。
    ''' </summary>
    ''' <returns>成功: 空文字 / 失敗: エラーメッセージ</returns>
    ''' <remarks>
    ''' access_token を SOAP API の sessionId として利用するため、DML / query 処理は変更不要。
    ''' 接続先 URL は instance_url + /services/Soap/c/{API バージョン}（Enterprise WSDL）。
    ''' 作成日: 2026/07/28 Nguyen Ngoc Quy
    ''' </remarks>
    Public Function login() As String
        ' セッション有効チェック
        Dim isLoginTimeout As Boolean = False
        Try
            Dim timeStamp As Date = m_Sforce.getServerTimestamp.timestamp
        Catch ex As Exception
            isLoginTimeout = True
        End Try

        If Not isLoginTimeout Then
            Return String.Empty
        End If

        Try
            ' タイムアウト設定
            Me.m_Sforce.Timeout = m_LoginTimeout

            ' Device Flow で access_token を取得する
            Dim oauth As New OAuthHelper(m_OAuthLoginUrl, m_ClientId, m_Scope,
                                         m_ProxyHost, m_ProxyPort, m_ProxyUser, m_ProxyPass)
            Dim oauthError As String = oauth.GetTokenByDeviceFlow()
            If Not String.IsNullOrEmpty(oauthError) Then
                Return oauthError
            End If

            ' プロキシ設定（SOAP 通信用）
            If Not String.IsNullOrWhiteSpace(m_ProxyHost) AndAlso Not String.IsNullOrWhiteSpace(m_ProxyPort) Then
                m_Sforce.Proxy = New Net.WebProxy(m_ProxyHost, CInt(m_ProxyPort))
                If Not String.IsNullOrWhiteSpace(m_ProxyUser) AndAlso Not String.IsNullOrWhiteSpace(m_ProxyPass) Then
                    m_Sforce.Proxy.Credentials = New System.Net.NetworkCredential(m_ProxyUser, m_ProxyPass)
                End If
            End If

            ' access_token = sessionId として設定する
            Me.m_Sforce.SessionHeaderValue = New SessionHeader With {.sessionId = oauth.AccessToken}
            ' instance_url + /services/Soap/c/{ver}（App.config の WSDL バージョンと一致させること）
            Me.m_Sforce.Url = oauth.InstanceUrl & String.Format(Constant.SoapEndpointFormat, Constant.SforceApiVersion)
            Me.m_LoginUrl = oauth.InstanceUrl

            Return String.Empty
        Catch ex As Exception
            Return ex.Message
        End Try
    End Function
#End Region

#Region "クエリー"
    ''' <summary>
    ''' クエリーを実行する。
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Function query(ByVal strQueryString As String) As QueryResult
        login()
        Return Me.m_Sforce.query(strQueryString)
    End Function

    ''' <summary>
    ''' queryMore を実行する。（2000 件超のページング）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Function queryMore(ByVal strQueryLocator As String) As QueryResult
        Return Me.m_Sforce.queryMore(strQueryLocator)
    End Function
#End Region

#Region "INSERT"
    ''' <summary>
    ''' 1 件挿入する。
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Function insert(ByVal sobj As sObject) As SaveResult
        Return insert(New sObject() {sobj})(0)
    End Function

    ''' <summary>
    ''' 複数件挿入する。（200 件ごとにバッチ分割）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Function insert(ByVal sobjArray() As sObject) As List(Of SaveResult)
        Dim intCntSend As Integer = 0
        Dim listSaveResult As New List(Of SaveResult)
        login()

        Dim intCnt As Integer = 0
        Dim intLen As Integer = 0
        While intCnt < sobjArray.Length
            If sobjArray.Length - intCnt < UPD_MAX_CNT Then
                intLen = sobjArray.Length - intCnt
            Else
                intLen = UPD_MAX_CNT
            End If

            Dim sObj(intLen - 1) As sObject
            Array.Copy(sobjArray, intCnt, sObj, 0, intLen)

            Dim saveResult() As SaveResult = Me.m_Sforce.create(sObj)
            listSaveResult.AddRange(saveResult)
            For i As Integer = 0 To saveResult.Length - 1
                If saveResult(i).success Then
                    sObj(i).Id = saveResult(i).id
                    errorArr.Add("")
                Else
                    errorArr.Add(getErrorMessage(saveResult(i).errors))
                End If
            Next
            intCnt += intLen

            ' 一定件数ごとに Sleep
            intCntSend += UPD_MAX_CNT
            If intCntSend >= m_SleepTime Then
                System.Threading.Thread.Sleep(m_SleepTime)
                intCntSend = 0
            End If
        End While
        Return listSaveResult
    End Function
#End Region

#Region "UPDATE"
    ''' <summary>
    ''' 1 件更新する。
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Function update(ByVal sobj As sObject) As SaveResult
        Return update(New sObject() {sobj})(0)
    End Function

    ''' <summary>
    ''' 複数件更新する。（200 件ごとにバッチ分割）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Function update(ByVal sobjArray() As sObject) As List(Of SaveResult)
        Dim intCntSend As Integer = 0
        Dim updateResultList As New List(Of SaveResult)
        login()

        Dim intCnt As Integer = 0
        Dim intLen As Integer = 0
        While intCnt < sobjArray.Length
            If sobjArray.Length - intCnt < UPD_MAX_CNT Then
                intLen = sobjArray.Length - intCnt
            Else
                intLen = UPD_MAX_CNT
            End If

            Dim sObj(intLen - 1) As sObject
            Array.Copy(sobjArray, intCnt, sObj, 0, intLen)

            Dim saveResult() As SaveResult = Me.m_Sforce.update(sObj)
            updateResultList.AddRange(saveResult)
            For i As Integer = 0 To saveResult.Length - 1
                If saveResult(i).success Then
                    sObj(i).Id = saveResult(i).id
                    errorArr.Add("")
                Else
                    errorArr.Add(getErrorMessage(saveResult(i).errors))
                End If
            Next
            intCnt += intLen

            intCntSend += UPD_MAX_CNT
            If intCntSend >= m_SleepTime Then
                System.Threading.Thread.Sleep(m_SleepTime)
                intCntSend = 0
            End If
        End While
        Return updateResultList
    End Function
#End Region

#Region "UPSERT"
    ''' <summary>
    ''' 複数件アップサートする。（200 件ごとにバッチ分割、外部キー指定）
    ''' </summary>
    ''' <param name="sobjArray">対象 sObject 配列</param>
    ''' <param name="externalField">外部キー項目 API 参照名</param>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Function upsert(ByVal sobjArray() As sObject, ByVal externalField As String) As List(Of UpsertResult)
        Dim intCntSend As Integer = 0
        Dim upsertResultList As New List(Of UpsertResult)
        login()

        Dim intCnt As Integer = 0
        Dim intLen As Integer = 0
        While intCnt < sobjArray.Length
            MainController.m_CommitCount += 1
            If sobjArray.Length - intCnt < UPD_MAX_CNT Then
                intLen = sobjArray.Length - intCnt
            Else
                intLen = UPD_MAX_CNT
            End If

            Dim sObj(intLen - 1) As sObject
            Array.Copy(sobjArray, intCnt, sObj, 0, intLen)

            Dim upsertResult() As UpsertResult = Me.m_Sforce.upsert(externalField, sObj)
            upsertResultList.AddRange(upsertResult)
            For i As Integer = 0 To upsertResult.Length - 1
                If upsertResult(i).success Then
                    sObj(i).Id = upsertResult(i).id
                    errorArr.Add("")
                Else
                    errorArr.Add(getErrorMessage(upsertResult(i).errors))
                End If
            Next
            intCnt += intLen

            intCntSend += UPD_MAX_CNT
            If intCntSend >= m_SleepTime Then
                System.Threading.Thread.Sleep(m_SleepTime)
                intCntSend = 0
            End If
        End While
        Return upsertResultList
    End Function
#End Region

#Region "DELETE"
    ''' <summary>
    ''' 複数件削除する。（200 件ごとにバッチ分割）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Function delete(ByVal sobjArray() As sObject) As List(Of DeleteResult)
        Dim intCntSend As Integer = 0
        Dim deleteResultList As New List(Of DeleteResult)
        login()

        Dim intCnt As Integer = 0
        Dim intLen As Integer = 0
        While intCnt < sobjArray.Length
            If sobjArray.Length - intCnt < UPD_MAX_CNT Then
                intLen = sobjArray.Length - intCnt
            Else
                intLen = UPD_MAX_CNT
            End If

            Dim sObj(intLen - 1) As sObject
            Dim delIdList(intLen - 1) As String
            Array.Copy(sobjArray, intCnt, sObj, 0, intLen)
            For i As Integer = 0 To sObj.Length - 1
                delIdList(i) = sObj(i).Id
            Next

            Dim deleteResult() As DeleteResult = Me.m_Sforce.delete(delIdList)
            deleteResultList.AddRange(deleteResult)
            For i As Integer = 0 To deleteResult.Length - 1
                If deleteResult(i).success Then
                    errorArr.Add("")
                Else
                    errorArr.Add(getErrorMessage(deleteResult(i).errors))
                End If
            Next
            intCnt += intLen

            intCntSend += UPD_MAX_CNT
            If intCntSend >= m_SleepTime Then
                System.Threading.Thread.Sleep(m_SleepTime)
                intCntSend = 0
            End If
        End While
        Return deleteResultList
    End Function
#End Region

#Region "補助"
    ''' <summary>
    ''' 書き込み可能なフィールド名を取得する。（数式・自動採番を除外）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Function getWriteableFields(ByVal sobjectName As String, ByVal fields As List(Of String)) As List(Of String)
        Try
            Dim writeableFields = m_Sforce.describeSObject(sobjectName).fields _
                .Where(Function(c) _
                          Not c.calculated AndAlso _
                          Not c.autoNumber AndAlso _
                          Not c.name.Contains("Specified") AndAlso _
                          fields.Contains(c.name)) _
                .Select(Function(p) p.name) _
                .ToList()
            Return writeableFields
        Catch ex As Exception
            Return New List(Of String)
        End Try
    End Function

    ''' <summary>
    ''' 空欄のフィールドを fieldsToNull に設定する。（update / upsert 用）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Sub setFieldToNull(ByVal obj As sObject, ByVal srcProperties As List(Of PropertyInfo))
        Dim fieldsToNull As New List(Of String)
        For Each srcProperty As PropertyInfo In srcProperties
            Dim value = srcProperty.GetValue(obj, Nothing)
            If value Is Nothing OrElse (TypeOf value Is String AndAlso String.IsNullOrWhiteSpace(CStr(value))) Then
                fieldsToNull.Add(srcProperty.Name)
                srcProperty.SetValue(obj, Nothing, Nothing)
            End If
        Next
        obj.fieldsToNull = fieldsToNull.ToArray
    End Sub

    ''' <summary>
    ''' エラー配列から先頭のメッセージを取得する。（空配列ガード）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Shared Function getErrorMessage(ByVal errors As [Error]()) As String
        If errors IsNot Nothing AndAlso errors.Length > 0 Then
            Return errors(0).message
        End If
        Return "Unknown error"
    End Function
#End Region

End Class
