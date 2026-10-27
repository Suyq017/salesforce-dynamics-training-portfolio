Imports System.IO
Imports System.Text

''' <summary>
''' ログ出力 クラス
''' </summary>
''' <remarks>
''' ・実行ログ … 連携設定情報の LogFolder に出力する。
''' ・EXE 隣接ログ … 連携設定情報が取得できないなど、LogFolder が未確定の場合に EXE と同じフォルダへ出力する。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy
''' </remarks>
Public Class LogFileHelper

    ''' <summary>
    ''' 実行ログを出力する。（LogFolder が無ければ作成）
    ''' </summary>
    ''' <param name="message">出力メッセージ</param>
    ''' <param name="fileName">ログファイル名</param>
    ''' <param name="isNewLine">True の場合、末尾に空行を追加する</param>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Sub writeExecLog(ByVal message As String, ByVal fileName As String, ByVal isNewLine As Boolean)
        If Not Directory.Exists(sysSetting.LogFolder) Then
            Directory.CreateDirectory(sysSetting.LogFolder)
        End If

        Using logWriter As New StreamWriter(sysSetting.LogFolder & fileName, True, Encoding.GetEncoding(Constant.TextEncoding))
            If isNewLine Then
                message = message & vbNewLine
            End If
            logWriter.WriteLine(message)
        End Using
    End Sub

    ''' <summary>
    ''' EXE と同じフォルダにログを出力する。（連携設定情報取得失敗など）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Sub writeLogNextToExe(ByVal message As String, ByVal fileName As String)
        Using logWriter As New StreamWriter(Constant.RootDirectory & fileName, True, Encoding.GetEncoding(Constant.TextEncoding))
            logWriter.WriteLine(message)
        End Using
    End Sub

    ''' <summary>
    ''' 保存日数を超えた古いログファイルを削除する。
    ''' </summary>
    ''' <param name="logFolder">ログフォルダ</param>
    ''' <param name="logDays">保存日数（0 以下の場合は削除しない）</param>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Sub deleteOldLog(ByVal logFolder As String, ByVal logDays As Integer)
        Try
            If logDays <= 0 OrElse Not Directory.Exists(logFolder) Then
                Return
            End If
            Dim limitDate As DateTime = DateTime.Now.AddDays(-logDays)
            For Each filePath As String In Directory.GetFiles(logFolder, "*.txt")
                If File.GetLastWriteTime(filePath) < limitDate Then
                    File.Delete(filePath)
                End If
            Next
        Catch ex As Exception
            ' 古いログ削除の失敗は処理継続とする
        End Try
    End Sub
End Class
