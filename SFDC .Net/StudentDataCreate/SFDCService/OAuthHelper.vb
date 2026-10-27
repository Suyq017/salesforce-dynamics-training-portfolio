Imports System.IO
Imports System.Net
Imports System.Text
Imports System.Threading
Imports System.Web.Script.Serialization
''' <summary>
''' OAuth 2.0 ヘルパー クラス（Device Flow）
''' </summary>
''' <remarks>
''' OAuth 2.0 Device Authorization Grant（Device Flow）で access_token を取得する。
''' 入力デバイスが限られた環境／ブラウザを直接開けない環境向け。
''' 取得した access_token は SOAP API の sessionId として利用する。
''' ※ access_token / secret はログに出力しないこと。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy
''' </remarks>
Public Class OAuthHelper

#Region "メンバ"
    Private m_LoginUrl As String  ' ログイン URL（例：https://login.salesforce.com）
    Private m_ClientId As String  ' Connected App の Consumer Key
    Private m_Scope As String     ' OAuth スコープ（任意）

    Private m_ProxyHost As String
    Private m_ProxyPort As String
    Private m_ProxyUser As String
    Private m_ProxyPass As String

    ' 取得結果
    Private m_AccessToken As String = String.Empty
    Public ReadOnly Property AccessToken As String
        Get
            Return m_AccessToken
        End Get
    End Property

    Private m_InstanceUrl As String = String.Empty
    Public ReadOnly Property InstanceUrl As String
        Get
            Return m_InstanceUrl
        End Get
    End Property
#End Region

#Region "コンストラクタ"
    ''' <summary>
    ''' コンストラクタ
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Sub New(ByVal loginUrl As String,
                   ByVal clientId As String,
                   ByVal scope As String,
                   ByVal proxyHost As String,
                   ByVal proxyPort As String,
                   ByVal proxyUser As String,
                   ByVal proxyPass As String)
        Me.m_LoginUrl = If(loginUrl, String.Empty).TrimEnd("/"c)
        Me.m_ClientId = clientId
        Me.m_Scope = scope
        Me.m_ProxyHost = proxyHost
        Me.m_ProxyPort = proxyPort
        Me.m_ProxyUser = proxyUser
        Me.m_ProxyPass = proxyPass
    End Sub
#End Region

#Region "Device Flow"
    ''' <summary>
    ''' Device Flow で access_token を取得する。
    ''' </summary>
    ''' <returns>成功: 空文字 / 失敗: エラーメッセージ</returns>
    ''' <remarks>
    ''' 1) デバイスコードを要求（response_type=device_code）
    ''' 2) verification_uri と user_code をユーザに提示
    ''' 3) grant_type=device で interval 秒ごとにポーリングし、認証完了で access_token を取得
    ''' 作成日: 2026/07/28 Nguyen Ngoc Quy
    ''' </remarks>
    Public Function GetTokenByDeviceFlow() As String
        ' TLS 1.2 を強制
        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12

        Dim tokenUrl As String = m_LoginUrl & Constant.OAuthTokenPath
        Dim serializer As New JavaScriptSerializer()

        ' 1) デバイスコード要求
        Dim initBody As New StringBuilder()
        initBody.Append("response_type=").Append(Constant.DeviceResponseType)
        initBody.Append("&client_id=").Append(Uri.EscapeDataString(m_ClientId))
        If Not String.IsNullOrWhiteSpace(m_Scope) Then
            initBody.Append("&scope=").Append(Uri.EscapeDataString(m_Scope))
        End If

        Dim initJson As String = postToken(tokenUrl, initBody.ToString())
        Dim initDict As Dictionary(Of String, Object) = serializer.Deserialize(Of Dictionary(Of String, Object))(initJson)

        If initDict Is Nothing OrElse Not initDict.ContainsKey("device_code") Then
            Return getOAuthError(initDict)
        End If

        Dim deviceCode As String = Convert.ToString(initDict("device_code"))
        Dim userCode As String = getValueOrEmpty(initDict, "user_code")
        Dim verificationUri As String = getVerificationUri(initDict)
        Dim interval As Integer = getIntValue(initDict, "interval", Constant.DefaultPollInterval)
        Dim expiresIn As Integer = getIntValue(initDict, "expires_in", Constant.DefaultDeviceExpire)
        ' 2) ユーザに認証を案内する
        MainController.writeConsoleLog(String.Format(Constant.DeviceVerifyMsg, verificationUri, userCode), True)

        ' 3) ポーリング
        Dim pollBody As String = "grant_type=" & Constant.DeviceGrantType &
                                 "&client_id=" & Uri.EscapeDataString(m_ClientId) &
                                 "&code=" & Uri.EscapeDataString(deviceCode)

        Dim elapsed As Integer = 0
        While elapsed < expiresIn
            Thread.Sleep(interval * 1000)
            elapsed += interval

            Dim pollJson As String = postToken(tokenUrl, pollBody)
            Dim pollDict As Dictionary(Of String, Object) = serializer.Deserialize(Of Dictionary(Of String, Object))(pollJson)

            If pollDict IsNot Nothing AndAlso pollDict.ContainsKey("access_token") Then
                ' 認証完了
                m_AccessToken = Convert.ToString(pollDict("access_token"))
                m_InstanceUrl = getValueOrEmpty(pollDict, "instance_url")
                Return String.Empty
            End If

            Dim oauthError As String = getValueOrEmpty(pollDict, "error")
            If String.Equals(oauthError, Constant.OAuthErrorPending, StringComparison.OrdinalIgnoreCase) Then
                ' 認証待ち → ポーリング継続
                Continue While
            ElseIf String.Equals(oauthError, Constant.OAuthErrorSlowDown, StringComparison.OrdinalIgnoreCase) Then
                ' ポーリング間隔を広げる
                interval += Constant.DefaultPollInterval
                Continue While
            ElseIf Not String.IsNullOrEmpty(oauthError) Then
                ' access_denied / expired_token など
                Return getOAuthError(pollDict)
            End If
        End While

        ' 有効期限内に認証されなかった
        Return Constant.ErrMsgLoginTimeout
    End Function
#End Region

#Region "補助"
    ''' <summary>
    ''' トークンエンドポイントへ POST する。（HTTP エラー時も応答本文を返す）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Function postToken(ByVal url As String, ByVal body As String) As String
        Dim request As HttpWebRequest = DirectCast(WebRequest.Create(url), HttpWebRequest)
        request.Method = "POST"
        request.ContentType = "application/x-www-form-urlencoded"
        setProxy(request)
        Dim data As Byte() = Encoding.UTF8.GetBytes(body)
        request.ContentLength = data.Length
        Using stream As Stream = request.GetRequestStream()
            stream.Write(data, 0, data.Length)
        End Using

        Try
            Using response As HttpWebResponse = DirectCast(request.GetResponse(), HttpWebResponse)
                Return readResponse(response)
            End Using
        Catch ex As WebException
            ' authorization_pending 等は HTTP 400 で返るため、応答本文を読み取る
            If ex.Response IsNot Nothing Then
                Using response As HttpWebResponse = DirectCast(ex.Response, HttpWebResponse)
                    Return readResponse(response)
                End Using
            End If
            Throw
        End Try
    End Function

    ''' <summary>応答本文を文字列で取得する。</summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Function readResponse(ByVal response As HttpWebResponse) As String
        Using reader As New StreamReader(response.GetResponseStream(), Encoding.UTF8)
            Return reader.ReadToEnd()
        End Using
    End Function

    ''' <summary>プロキシを設定する。</summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Sub setProxy(ByVal request As HttpWebRequest)
        If Not String.IsNullOrWhiteSpace(m_ProxyHost) AndAlso Not String.IsNullOrWhiteSpace(m_ProxyPort) Then
            Dim proxy As New WebProxy(m_ProxyHost, CInt(m_ProxyPort))
            If Not String.IsNullOrWhiteSpace(m_ProxyUser) AndAlso Not String.IsNullOrWhiteSpace(m_ProxyPass) Then
                proxy.Credentials = New NetworkCredential(m_ProxyUser, m_ProxyPass)
            End If
            request.Proxy = proxy
        End If
    End Sub

    ''' <summary>OAuth エラー応答から「error: error_description」形式のメッセージを組み立てる。</summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Function getOAuthError(ByVal dict As Dictionary(Of String, Object)) As String
        If dict Is Nothing Then
            Return "OAuth error"
        End If
        Dim errorCode As String = getValueOrEmpty(dict, "error")
        Dim errorDesc As String = getValueOrEmpty(dict, "error_description")
        If String.IsNullOrEmpty(errorCode) AndAlso String.IsNullOrEmpty(errorDesc) Then
            Return "OAuth error"
        End If
        Return (errorCode & "：" & errorDesc).Trim(CChar("："))
    End Function

    ''' <summary>Dictionary から文字列値を取得する。（無ければ空文字）</summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Function getValueOrEmpty(ByVal dict As Dictionary(Of String, Object), ByVal key As String) As String
        If dict IsNot Nothing AndAlso dict.ContainsKey(key) AndAlso dict(key) IsNot Nothing Then
            Return Convert.ToString(dict(key))
        End If
        Return String.Empty
    End Function

    ''' <summary>Dictionary から数値を取得する。（無ければ defaultValue）</summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Function getIntValue(ByVal dict As Dictionary(Of String, Object), ByVal key As String, ByVal defaultValue As Integer) As Integer
        Try
            If dict IsNot Nothing AndAlso dict.ContainsKey(key) AndAlso dict(key) IsNot Nothing Then
                Return Convert.ToInt32(dict(key))
            End If
        Catch
        End Try
        Return defaultValue
    End Function

    ''' <summary>verification_uri_complete があれば優先し、無ければ verification_uri を返す。</summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Function getVerificationUri(ByVal dict As Dictionary(Of String, Object)) As String
        Dim uriComplete As String = getValueOrEmpty(dict, "verification_uri_complete")
        If Not String.IsNullOrEmpty(uriComplete) Then
            Return uriComplete
        End If
        Return getValueOrEmpty(dict, "verification_uri")
    End Function
#End Region

End Class
