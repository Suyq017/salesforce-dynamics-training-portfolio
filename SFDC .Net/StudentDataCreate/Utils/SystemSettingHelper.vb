Option Explicit On
Option Strict On
Imports System.Xml

''' <summary>
''' 連携設定情報 / ログイン情報 処理クラス
''' </summary>
''' <remarks>
''' SystemSetting.xml と LoginInfo.xml を読み込む。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy
''' </remarks>
Class SystemSettingHelper

#Region "メンバ（LoginInfo.xml）"
    Private m_ClientId As String
    Public ReadOnly Property ClientId As String
        Get
            Return m_ClientId
        End Get
    End Property

    Private m_LoginUrl As String
    Public ReadOnly Property LoginUrl As String
        Get
            Return m_LoginUrl
        End Get
    End Property

    Private m_Scope As String
    Public ReadOnly Property Scope As String
        Get
            Return m_Scope
        End Get
    End Property

    Private m_ProxyHost As String
    Public ReadOnly Property ProxyHost As String
        Get
            Return m_ProxyHost
        End Get
    End Property

    Private m_ProxyPort As String
    Public ReadOnly Property ProxyPort As String
        Get
            Return m_ProxyPort
        End Get
    End Property

    Private m_ProxyUserName As String
    Public ReadOnly Property ProxyUserName As String
        Get
            Return m_ProxyUserName
        End Get
    End Property

    Private m_ProxyPassword As String
    Public ReadOnly Property ProxyPassword As String
        Get
            Return m_ProxyPassword
        End Get
    End Property
#End Region

#Region "メンバ（SystemSetting.xml）"
    Private m_InputFolder As String
    Public ReadOnly Property InputFolder As String
        Get
            Return m_InputFolder
        End Get
    End Property

    Private m_LogFolder As String
    Public ReadOnly Property LogFolder As String
        Get
            Return m_LogFolder
        End Get
    End Property

    Private m_HistoryDataFolder As String
    Public ReadOnly Property HistoryDataFolder As String
        Get
            Return m_HistoryDataFolder
        End Get
    End Property

    Private m_InputFileName As String
    Public ReadOnly Property InputFileName As String
        Get
            Return m_InputFileName
        End Get
    End Property

    Private m_LogDays As Integer
    Public ReadOnly Property LogDays As Integer
        Get
            Return m_LogDays
        End Get
    End Property
#End Region

#Region "ログイン情報取得（LoginInfo.xml）"
    ''' <summary>
    ''' LoginInfo.xml を読み込む。
    ''' </summary>
    ''' <returns>成功: True / 失敗: False</returns>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Function getLoginInfo() As Boolean
        Try
            Dim xmlSetting As New XmlReaderSettings()
            With xmlSetting
                .ConformanceLevel = ConformanceLevel.Fragment
                .IgnoreWhitespace = True
                .IgnoreComments = True
            End With
            Using reader As XmlReader = XmlReader.Create(Constant.RootDirectory & Constant.LoginInfoFile, xmlSetting)
                reader.Read()
                ' Connected App の Consumer Key
                reader.ReadToFollowing("clientid")
                m_ClientId = reader.ReadString
                ' ログイン URL
                reader.ReadToFollowing("loginurl")
                m_LoginUrl = reader.ReadString
                ' OAuth スコープ
                reader.ReadToFollowing("scope")
                m_Scope = reader.ReadString
                ' プロキシーホスト名
                reader.ReadToFollowing("proxy_host")
                m_ProxyHost = reader.ReadString
                ' プロキシーポート番号
                reader.ReadToFollowing("proxy_port")
                m_ProxyPort = reader.ReadString
                ' プロキシーユーザID
                reader.ReadToFollowing("proxy_username")
                m_ProxyUserName = reader.ReadString
                ' プロキシーパスワード
                reader.ReadToFollowing("proxy_password")
                m_ProxyPassword = reader.ReadString
            End Using

            ' 必須項目チェック（clientid / loginurl）
            If String.IsNullOrWhiteSpace(m_ClientId) OrElse String.IsNullOrWhiteSpace(m_LoginUrl) Then
                Return False
            End If
            Return True
        Catch ex As Exception
            Return False
        End Try
    End Function
#End Region

#Region "連携設定情報取得（SystemSetting.xml）"
    ''' <summary>
    ''' SystemSetting.xml を読み込む。
    ''' </summary>
    ''' <returns>成功: True / 失敗: False</returns>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Function getSystemSetting() As Boolean
        Try
            Dim xmlSetting As New XmlReaderSettings()
            With xmlSetting
                .ConformanceLevel = ConformanceLevel.Fragment
                .IgnoreWhitespace = True
                .IgnoreComments = True
            End With

            Using reader As XmlReader = XmlReader.Create(Constant.RootDirectory & Constant.SystemSettingFile, xmlSetting)
                reader.Read()

                ' 学生一覧情報フォルダ
                reader.ReadToFollowing("InputFolder")
                m_InputFolder = reader.ReadString
                If String.IsNullOrWhiteSpace(m_InputFolder) Then
                    Return False
                End If
                m_InputFolder = Common.getAbsPath(m_InputFolder)

                ' LOG フォルダ
                reader.ReadToFollowing("LogFolder")

                m_LogFolder = reader.ReadString
                If String.IsNullOrWhiteSpace(m_LogFolder) Then
                    Return False
                End If
                m_LogFolder = Common.getAbsPath(m_LogFolder)

                ' 履歴フォルダ
                reader.ReadToFollowing("HistoryDataFolder")
                m_HistoryDataFolder = reader.ReadString
                If Not String.IsNullOrWhiteSpace(m_HistoryDataFolder) Then
                    m_HistoryDataFolder = Common.getAbsPath(m_HistoryDataFolder)
                End If

                ' 学生一覧情報ファイル名
                reader.ReadToFollowing("InputFile1")
                m_InputFileName = reader.ReadString
                If String.IsNullOrWhiteSpace(m_InputFileName) Then
                    Return False
                End If

                ' LOG ファイル保存日数
                reader.ReadToFollowing("LogDays")
                Dim logDaysStr As String = reader.ReadString
                If Not Integer.TryParse(logDaysStr, m_LogDays) Then
                    m_LogDays = 0
                End If
            End Using
            Return True
        Catch ex As Exception
            Return False
        End Try
    End Function
#End Region

End Class
