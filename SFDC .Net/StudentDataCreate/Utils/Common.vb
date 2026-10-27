Option Explicit On
Option Strict On

Imports System.IO
Imports System.Globalization
Imports System.Text.RegularExpressions

''' <summary>
''' 共通ユーティリティ クラス
''' </summary>
''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
Public Class Common

    ''' <summary>
    ''' 相対パスを絶対パスに変換する。（末尾に "\" を付与）
    ''' </summary>
    ''' <param name="relativePath">相対パス</param>
    ''' <returns>絶対パス</returns>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Function getAbsPath(Optional ByVal relativePath As String = "") As String
        Dim regex As Regex = New Regex("^([A-Za-z])[:]\\")
        Dim absPath As String = CStr(IIf(String.IsNullOrEmpty(relativePath), Directory.GetCurrentDirectory(), relativePath))
        If Not regex.IsMatch(absPath) Then
            absPath = Path.GetFullPath(absPath)
        End If
        If Not absPath.EndsWith("\") Then
            absPath += "\"
        End If
        Return absPath
    End Function

    ''' <summary>
    ''' ログ出力用の日時プレフィックスを付与する。
    ''' </summary>
    ''' <param name="message">メッセージ本体</param>
    ''' <returns>「yyyyMMddHHmmss　メッセージ」形式の文字列</returns>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Function getPrefixOfLogString(ByVal message As String) As String
        Return DateTime.Now.ToString(Constant.DateTimeFormat) & "　" & message
    End Function

    ''' <summary>
    ''' CSV 行内の "NULL" 文字列を空文字に変換する。
    ''' </summary>
    ''' <param name="csvRow">CSV 1 行分の配列</param>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Sub replaceNullString(ByVal csvRow As String())
        For i As Integer = 0 To csvRow.Length - 1
            If csvRow(i) IsNot Nothing AndAlso String.Equals(csvRow(i).Trim(), Constant.NullString, StringComparison.OrdinalIgnoreCase) Then
                csvRow(i) = String.Empty
            End If
        Next
    End Sub

    ''' <summary>
    ''' 文字列を Nullable(Of Date) に変換する。（変換失敗時は Nothing）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Function ToDateNullable(ByVal input As String, ByVal format As String) As Date?
        Dim result As Date
        If Date.TryParseExact(input, format, CultureInfo.InvariantCulture, DateTimeStyles.None, result) Then
            Return result
        End If
        If Date.TryParse(input, result) Then
            Return result
        End If
        Return Nothing
    End Function

    ''' <summary>
    ''' 文字列を Nullable(Of Double) に変換する。（変換失敗時は defaultValue）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Function ToDoubleNullAble(ByVal input As String, ByVal defaultValue As Double?) As Double?
        Dim result As Double
        If Double.TryParse(input, result) Then
            Return result
        End If
        Return defaultValue
    End Function
End Class
