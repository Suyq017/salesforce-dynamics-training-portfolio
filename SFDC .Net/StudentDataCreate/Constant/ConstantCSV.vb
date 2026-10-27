''' <summary>
''' CSV 定数 クラス（学生一覧情報ファイル）
''' </summary>
''' <remarks>
''' 学生一覧情報ファイルの列インデックスと欄数を定義する。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy
''' </remarks>
Public Class ConstantCSV
    ' 欄数（この件数以外は FORMAT 不正）
    Public Const NumberOfColumnCSV As Integer = 7

    ' 列インデックス
    Public Const Col_UpdateKey As Integer = 0      ' .NetKey（Upsert キー）
    Public Const Col_LastName As Integer = 1       ' 姓
    Public Const Col_FirstName As Integer = 2      ' 名
    Public Const Col_ClassName As Integer = 3      ' クラス名（Class__c.Name）
    Public Const Col_Gender As Integer = 4         ' 性別（Male / Female）
    Public Const Col_Birthday As Integer = 5       ' 生年月日（yyyy/MM/dd）
    Public Const Col_LearningStatus As Integer = 6 ' 学習状況（Enrolled / Withdrawn / Graduated）
End Class
