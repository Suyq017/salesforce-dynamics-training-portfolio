Imports Microsoft.VisualBasic.FileIO
Imports System.IO
Imports System.Text

''' <summary>
''' CSV ファイル処理 クラス
''' </summary>
''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
Public Class CsvFileHelper

    ''' <summary>
    ''' CSV ファイルを読み込み、行ごとの配列リストに変換する。
    ''' </summary>
    ''' <param name="csvFile">CSV ファイルの絶対パス</param>
    ''' <returns>1 行 = String() のリスト（ヘッダ行を含む）</returns>
    ''' <remarks>
    ''' ダブルクォート囲み・セル内改行に対応する。
    ''' 作成日: 2026/07/28 Nguyen Ngoc Quy
    ''' </remarks>
    Public Shared Function getCsvRowList(ByVal csvFile As String) As List(Of String())
        Dim csvRowList As New List(Of String())
        Using csvReader As New TextFieldParser(csvFile, Encoding.GetEncoding(Constant.TextEncoding)) With {
               .TextFieldType = FileIO.FieldType.Delimited,
               .Delimiters = New String() {Constant.CsvDelimiter},
               .HasFieldsEnclosedInQuotes = True}
            Do While Not csvReader.EndOfData
                csvRowList.Add(csvReader.ReadFields())
            Loop
        End Using
        Return csvRowList
    End Function

    ''' <summary>
    ''' CSV ファイルを作成する。（フォルダが無ければ作成）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Sub createFileCSV(ByVal csvPathName As String, ByVal csvFileName As String, ByVal csvContentList As List(Of String()))
        If Not Directory.Exists(csvPathName) Then
            Directory.CreateDirectory(csvPathName)
        End If

        Using fileWriter As New StreamWriter(csvPathName & csvFileName, False, Encoding.GetEncoding(Constant.TextEncoding))
            For Each row As String() In csvContentList
                fileWriter.WriteLine(String.Join(Constant.CsvDelimiter, row))
            Next
        End Using
    End Sub
End Class
