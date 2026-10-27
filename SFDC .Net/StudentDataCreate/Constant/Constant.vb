''' <summary>
''' 定数 クラス
''' </summary>
''' <remarks>
''' 学生連携.Net（StudentDataCreate）で使用する共通定数・メッセージを定義する。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy
''' </remarks>
Public Class Constant

#Region "設定ファイル"
    Public Const LoginInfoFile As String = "LoginInfo.xml"       ' ログイン情報ファイル
    Public Const SystemSettingFile As String = "SystemSetting.xml" ' 連携設定情報ファイル

    ' 設定ファイル・ログを配置する EXE と同じフォルダ
    Public Shared ReadOnly RootDirectory As String = Common.getAbsPath()
#End Region

#Region "バージョン"
    ' プログラム内で定数として管理するバージョン
    Public Const ProgramVersion As String = "0.1"
#End Region

#Region "日時フォーマット"
    Public Const DateTimeFormat As String = "yyyyMMddHHmmss"
    Public Const DateFormatYmd As String = "yyyyMMdd"
    Public Const BirthdayFormat As String = "yyyy/MM/dd" ' CSV の生年月日フォーマット
#End Region

#Region "ログファイル"
    ' 実行ログファイル名（StudentDataCreate実行ログ_yyyymmdd.txt）
    Public Const ExecuteLogFileName As String = "StudentDataCreate実行ログ_{0}.txt"
#End Region

#Region "OAuth 2.0 Device Flow"
    ' トークンエンドポイント（loginurl に連結して使用）
    Public Const OAuthTokenPath As String = "/services/oauth2/token"

    ' Device Flow パラメータ
    Public Const DeviceResponseType As String = "device_code" ' デバイスコード要求
    Public Const DeviceGrantType As String = "device"         ' トークンポーリング

    ' ポーリング間隔・有効期限のデフォルト（秒）
    Public Const DefaultPollInterval As Integer = 5
    Public Const DefaultDeviceExpire As Integer = 600

    ' 認証待ち以外のポーリング応答（この 2 つはポーリング継続）
    Public Const OAuthErrorPending As String = "authorization_pending"
    Public Const OAuthErrorSlowDown As String = "slow_down"

    ' SOAP エンドポイント（Enterprise WSDL）。{0}=API バージョン
    Public Const SoapEndpointFormat As String = "/services/Soap/c/{0}"
    ' API バージョン（※ 取り込んだ WSDL と必ず一致させること）
    Public Const SforceApiVersion As String = "67.0"

    ' 認証案内メッセージ（コンソール表示用）。{0}=verification_uri {1}=user_code
    Public Const DeviceVerifyMsg As String = "ブラウザで下記 URL を開き、ユーザコードを入力して認証してください。URL：{0}  ユーザコード：{1}"
#End Region

#Region "CSV / Upsert"
    Public Const TextEncoding As String = "UTF-8"     ' エンコーディング
    Public Const CsvFileExtension As String = ".csv"  ' CSV ファイル拡張子
    Public Const CsvDelimiter As String = ","         ' CSV 区切り文字
    Public Const NullString As String = "NULL"        ' 空値として扱う文字列

    ' Upsert 外部キー（.NetKey）
    Public Const ExternalFieldUpsert As String = "UpdateKey__c"
#End Region

#Region "Exit コード"
    ' 1 = 正常終了、0 = 異常終了
    Public Const ExitCodeSuccess As Integer = 1
    Public Const ExitCodeError As Integer = 0
#End Region

#Region "オブジェクト / 項目"
    Public Const NameObjectStudent As String = "Student__c"
    Public Const ProcessName As String = "StudentDataCreate" ' 二重起動チェック用プロセス名

    ' Upsert 対象項目（空欄は fieldsToNull へ設定する対象）
    Public Shared ReadOnly NamesFieldStudentUpsert As New List(Of String) From {
        "Name", "Firstname__c", "Lastname__c", "Class_look__c",
        "Gender__c", "Birthday__c", "LearningStatus__c", "UpdateKey__c"}
#End Region

#Region "正常メッセージ（1-x）"
    ' 1-1 開始
    Public Const StartProgramMsg As String = "プログラム START  Version:{0}"
    ' 1-2 ログイン成功
    Public Const LoginSuccessMsg As String = "ログイン成功：{0}"
    ' 1-3 学生一覧情報取得件数
    Public Const StudentGetCountMsg As String = "学生一覧情報　取得件数：{0}件"
    ' 1-4 学生一覧登録件数
    Public Const StudentUpsertCountMsg As String = "学生一覧登録　登録対象件数:{0}件　登録成功件数:{1}件 登録失敗件数:{2}件"
    ' 1-5 終了

    Public Const StudentGetCommitCountMsg As String = "学生一覧情報　登録コミット件数：{0}件"
    Public Const EndProgramMsg As String = "プログラム　END"
#End Region

#Region "エラーメッセージ（2-x）"
    ' 二重起動
    Public Const ErrMsgDuplicate As String = "二重起動を検出しました。処理を中止します。"
    ' 2-1 連携設定情報取得失敗（EXE と同じフォルダに出力）
    Public Const ErrMsgGetSysSetting As String = "連携設定情報取得失敗"
    ' 2-2 ログイン情報取得失敗
    Public Const ErrMsgGetLoginInfo As String = "ログイン情報取得失敗"
    ' 2-3 ログイン失敗
    Public Const ErrMsgLoginFail As String = "ログイン失敗：{0}"
    ' ログインタイムアウト（Device Flow の認証待ちタイムアウト）
    Public Const ErrMsgLoginTimeout As String = "ログインがタイムアウトしました。"
    ' 2-4 学生一覧情報ファイルなし
    Public Const ErrMsgInputFileNotFound As String = "学生一覧情報ファイルなし"
    ' 2-5 学生一覧情報ファイルFORMAT不正
    Public Const ErrMsgInputFileFormat As String = "学生一覧情報ファイルFORMAT不正"
    ' 2-6 クラスが存在なし
    Public Const ErrMsgClassNotExist As String = "クラスが存在なし：{0}"
    ' 2-7 学生一覧Insert失敗
    Public Const ErrMsgStudentUpsertFail As String = "学生一覧登録失敗　：{0}"
    ' 2-8 例外発生
    Public Const ErrMsgException As String = "システムエラー発生　{0}"
#End Region

#Region ".Netログ ステータス"
    Public Const NetLogStatusSuccess As String = "正常終了"
    Public Const NetLogStatusPartialFail As String = "一部登録失敗"
    Public Const NetLogStatusAllFail As String = "全件登録失敗"
    Public Const NetLogStatusAbnormal As String = "異常終了"
#End Region

#Region "その他"
    Public Const UPD_MAX_CNT As Integer = 200
#End Region

End Class
