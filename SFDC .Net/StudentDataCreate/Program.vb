''' <summary>
''' エントリーポイント / 共通グローバル変数
''' </summary>
''' <remarks>
''' 学生連携.Net（StudentDataCreate）のエントリーポイント。
''' DAO から直接参照できるように sfdcService / sysSetting を Module のグローバル変数として保持する。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy
''' </remarks>
Module Program
    ' 連携設定情報・ログイン情報
    Public ReadOnly sysSetting As New SystemSettingHelper
    ' Salesforce 接続サービス
    Public sfdcService As SFDCHelper
    ' DML エラーメッセージ格納用
    Public errorArr As New List(Of String)

    Sub Main()
        Dim main As New MainController
        main.ExecuteProcess()
    End Sub
End Module
