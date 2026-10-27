Imports StudentDataCreate.WebReference

''' <summary>
''' .Netログ DAO クラス
''' </summary>
''' <remarks>
''' 処理開始時に NetLog__c を作成し、終了時に件数・ステータス・終了時間を更新する。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy
''' </remarks>
Public Class NetLogDAO

    ''' <summary>
    ''' .Netログを作成し、開始時間を設定する。
    ''' </summary>
    ''' <param name="startTime">処理開始時間</param>
    ''' <returns>作成した NetLog__c の Id（失敗時は空文字）</returns>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Function createNetLog(ByVal startTime As DateTime) As String
        Dim objNetLog As New NetLog__c
        objNetLog.StartTime__c = startTime
        objNetLog.StartTime__cSpecified = True

        Dim result As SaveResult = sfdcService.insert(objNetLog)
        If result IsNot Nothing AndAlso result.success Then
            Return result.id
        End If
        Return String.Empty
    End Function

    ''' <summary>
    ''' .Netログを更新する。（終了時間・ステータス・各件数・エラーメッセージ）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Sub updateNetLog(ByVal netLogId As String,
                                   ByVal endTime As DateTime,
                                   ByVal status As String,
                                   ByVal inputCount As Integer,
                                   ByVal insertCount As Integer,
                                   ByVal insertOKCount As Integer,
                                   ByVal insertNGCount As Integer,
                                   ByVal errorMessage As String)
        If String.IsNullOrEmpty(netLogId) Then
            Return
        End If

        Dim objNetLog As New NetLog__c
        objNetLog.Id = netLogId
        ' 終了日
        objNetLog.EndTime__c = endTime
        objNetLog.EndTime__cSpecified = True
        ' 状態
        objNetLog.Status__c = status
        ' 入力ファイル件数
        objNetLog.InputCount__c = inputCount
        objNetLog.InputCount__cSpecified = True
        ' 登録対象件数
        objNetLog.InsertCount__c = insertCount
        objNetLog.InsertCount__cSpecified = True
        ' 登録成功件数
        objNetLog.InsertOKCount__c = insertOKCount
        objNetLog.InsertOKCount__cSpecified = True
        ' 登録失敗件数
        objNetLog.InsertNGCount__c = insertNGCount
        objNetLog.InsertNGCount__cSpecified = True
        ' エラーメッセージ
        If Not String.IsNullOrEmpty(errorMessage) Then
            objNetLog.ErrorMessage__c = errorMessage
        End If
        sfdcService.update(objNetLog)
    End Sub
End Class
