Imports StudentDataCreate.WebReference
Imports System.Reflection

''' <summary>
''' 学生 DAO クラス
''' </summary>
''' <remarks>
''' CSV 1 行を Student__c に変換し、Upsert（外部キー：UpdateKey__c）を行う。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy
''' </remarks>
Public Class StudentDAO

    ''' <summary>
    ''' CSV 1 行から Student__c を作成する。
    ''' </summary>
    ''' <param name="csvRow">CSV 1 行分の配列</param>
    ''' <param name="classId">紐付けるクラス（Class__c）の Id</param>
    ''' <param name="srcProperties">空欄時に fieldsToNull へ設定する項目</param>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Function createStudent(ByVal csvRow As String(),
                                         ByVal classId As String,
                                         ByVal srcProperties As List(Of PropertyInfo)) As Student__c
        Dim objStudent As New Student__c

        ' 学生名（Name）= 姓 + 名
        objStudent.Name = (csvRow(ConstantCSV.Col_LastName) & " " & csvRow(ConstantCSV.Col_FirstName)).Trim()
        ' 姓
        objStudent.Lastname__c = csvRow(ConstantCSV.Col_LastName)
        ' 名
        objStudent.Firstname__c = csvRow(ConstantCSV.Col_FirstName)
        ' クラス（Lookup）
        objStudent.Class_look__c = classId
        ' 性別
        objStudent.Gender__c = csvRow(ConstantCSV.Col_Gender)
        ' 生年月日
        Dim birthday As Date? = Common.ToDateNullable(csvRow(ConstantCSV.Col_Birthday), Constant.BirthdayFormat)
        If birthday.HasValue Then
            objStudent.Birthday__c = birthday.Value
            objStudent.Birthday__cSpecified = True
        End If
        ' 学習状況
        objStudent.LearningStatus__c = csvRow(ConstantCSV.Col_LearningStatus)
        ' .NetKey（Upsert キー）
        objStudent.UpdateKey__c = csvRow(ConstantCSV.Col_UpdateKey)

        ' 空欄フィールドを Nothing に設定する
        sfdcService.setFieldToNull(objStudent, srcProperties)
        Return objStudent
    End Function

    ''' <summary>
    ''' Student__c を Upsert する。（外部キー：UpdateKey__c）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Function upsertStudent(ByVal studentList As List(Of Student__c)) As List(Of UpsertResult)
        If IsNothing(studentList) OrElse Not studentList.Any Then
            Return New List(Of UpsertResult)
        End If
        Return sfdcService.upsert(studentList.ToArray(), Constant.ExternalFieldUpsert)
    End Function

    ''' <summary>
    ''' 書き込み可能な項目の PropertyInfo を取得する。（fieldsToNull 判定用）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Function getFieldToNull(ByVal nameObject As String, ByVal nameFields As List(Of String)) As List(Of PropertyInfo)
        Dim writeableFields As List(Of String) = sfdcService.getWriteableFields(nameObject, nameFields)
        Dim srcProperties = GetType(Student__c).GetProperties().Where(Function(c) writeableFields.Contains(c.Name)).ToList()
        Return srcProperties
    End Function
End Class
