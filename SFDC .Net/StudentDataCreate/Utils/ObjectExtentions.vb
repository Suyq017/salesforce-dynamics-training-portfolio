Imports System.Collections.Generic

''' <summary>
''' オブジェクトの拡張機能 クラス
''' </summary>
''' <remarks>
''' SOQL の IN 句が長くなり過ぎないよう、リストを一定サイズに分割する。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy
''' </remarks>
Public Class ObjectExtensions
    Private Sub New()
    End Sub

    ''' <summary>
    ''' リストを chunkSize ごとに分割する。
    ''' </summary>
    ''' <param name="source">分割対象リスト</param>
    ''' <param name="chunkSize">1 チャンクの最大件数</param>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Function Chunk(ByVal source As List(Of String), Optional ByVal chunkSize As Integer = 500) As List(Of List(Of String))
        Dim retVal As New List(Of List(Of String))
        Dim index As Integer = 0
        While index < source.Count
            Dim count As Integer = If(source.Count - index > chunkSize, chunkSize, source.Count - index)
            retVal.Add(source.GetRange(index, count))
            index += chunkSize
        End While
        Return retVal
    End Function
End Class
