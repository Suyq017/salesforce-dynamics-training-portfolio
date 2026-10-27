Imports StudentDataCreate.WebReference

''' <summary>
''' クラス DAO クラス
''' </summary>
''' <remarks>
''' クラス名（Class__c.Name）をキーに Class__c を取得する。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy
''' </remarks>
Public Class ClassDAO

    ''' <summary>
    ''' クラス名リストから Class__c を取得する。（IN 句、queryMore 対応）
    ''' </summary>
    ''' <param name="classNameList">クラス名のリスト</param>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Function getClassByName(ByVal classNameList As List(Of String)) As List(Of Class__c)
        Dim classList As New List(Of Class__c)
        If IsNothing(classNameList) OrElse Not classNameList.Any Then
            Return classList
        End If

        For Each partList As List(Of String) In ObjectExtensions.Chunk(classNameList)
            Dim soql As String = "SELECT Id, Name FROM Class__c "
            soql += "WHERE Name IN ('" & String.Join("','", partList.ToArray()) & "')"

            Dim qResult = sfdcService.query(soql)
            Dim qContinue As Boolean = True

            If Not IsNothing(qResult) AndAlso qResult.size > 0 Then
                While qContinue
                    For Each record As Class__c In qResult.records
                        classList.Add(record)
                    Next

                    If qResult.done Then
                        qContinue = False
                    Else
                        qResult = sfdcService.queryMore(qResult.queryLocator)
                    End If
                End While
            End If
        Next
        Return classList
    End Function
End Class
