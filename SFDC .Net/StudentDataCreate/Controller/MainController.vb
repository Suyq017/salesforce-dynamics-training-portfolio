Imports System.IO
Imports System.Reflection
Imports System.Diagnostics
Imports StudentDataCreate.WebReference

''' <summary>
''' 主処理 コントローラー クラス
''' </summary>
''' <remarks>
''' 学生連携.Net（StudentDataCreate）の全体フローを制御する。
''' ExecuteProcess() が 1.0 initProcess → 2.0 mainProcess → 3.0 finishProcess を順に呼び出し、
''' 例外発生時は 99.0 例外処理を行う。
''' 作成日: 2026/07/28 Nguyen Ngoc Quy Nguyen Ngoc Quy
''' </remarks>
Public Class MainController

#Region "メンバ（各処理で共有する状態）"
    ' 実行ログファイル名（StudentDataCreate実行ログ_yyyymmdd.txt）
    Private m_ExecuteLogFileName As String = String.Empty
    ' 作成した .Netログ（NetLog__c）の Id
    Private m_NetLogId As String = String.Empty

    ' 2.2 カウンター
    Private m_InputCount As Integer = 0    ' 入力ファイル件数
    Private m_InsertCount As Integer = 0   ' 登録対象件数
    Private m_InsertOKCount As Integer = 0 ' 登録成功件数
    Private m_InsertNGCount As Integer = 0 ' 登録失敗件数
    Public Shared m_CommitCount As Integer = 0   ' 挿入バッチ数

    ' .Netログ 用エラーメッセージ
    Private m_ErrorMessageList As New List(Of String)
    ' Salesforce ステータス（正常終了 / 一部登録失敗 / 全件登録失敗）
    Private m_ResultStatus As String = String.Empty
#End Region

    ''' <summary>
    ''' 全体処理を実行する。（1.0 → 2.0 → 3.0、例外時は 99.0）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy Nguyen Ngoc Quy</remarks>
    Public Sub ExecuteProcess()
        m_ExecuteLogFileName = String.Format(Constant.ExecuteLogFileName, DateTime.Now.ToString(Constant.DateFormatYmd))

        Try
            ' 1.0 初期処理
            initProcess()

            ' 2.0 主処理
            mainProcess()

            ' 3.0 終了処理
            finishProcess()

            Environment.Exit(Constant.ExitCodeSuccess)
        Catch ex As Exception
            ' 99.0 例外処理
            exceptionProcess(ex)
            Environment.Exit(Constant.ExitCodeError)
        End Try
    End Sub

#Region "1.0 初期処理"
    ''' <summary>
    ''' 1.0 初期処理。
    ''' 二重起動チェック → 連携設定情報取得 → 実行ログ作成 → ログイン情報取得 → ログイン → .Netログ作成。
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy Nguyen Ngoc Quy</remarks>
    Private Sub initProcess()
        ' 1.1 二重起動チェック
        If isDuplicateProcess() Then
            LogFileHelper.writeLogNextToExe(Common.getPrefixOfLogString(Constant.ErrMsgDuplicate), m_ExecuteLogFileName)
            writeConsoleLog(Constant.ErrMsgDuplicate, True)
            Environment.Exit(Constant.ExitCodeError)
        End If

        ' 1.2 連携設定情報取得（SystemSetting.xml）
        If Not sysSetting.getSystemSetting() Then
            ' 2-1：EXE と同じフォルダに出力
            LogFileHelper.writeLogNextToExe(Common.getPrefixOfLogString(Constant.ErrMsgGetSysSetting), m_ExecuteLogFileName)
            writeConsoleLog(Constant.ErrMsgGetSysSetting, True)
            Environment.Exit(Constant.ExitCodeError)
        End If

        ' 1.3 実行ログ作成 + 開始メッセージ（1-1）
        Dim startProgramMessage As String = String.Format(Constant.StartProgramMsg, Constant.ProgramVersion)
        LogFileHelper.writeExecLog(Common.getPrefixOfLogString(startProgramMessage), m_ExecuteLogFileName, False)

        ' 1.4 ログイン情報取得（LoginInfo.xml）
        If Not sysSetting.getLoginInfo() Then
            ' 2-2
            LogFileHelper.writeExecLog(Common.getPrefixOfLogString(Constant.ErrMsgGetLoginInfo), m_ExecuteLogFileName, False)
            writeConsoleLog(Constant.ErrMsgGetLoginInfo, True)
            Environment.Exit(Constant.ExitCodeError)
        End If

        ' 1.5 Salesforce ログイン（OAuth 2.0 Device Flow）
        sfdcService = New SFDCHelper(sysSetting.ClientId,
                                     sysSetting.LoginUrl,
                                     sysSetting.Scope,
                                     sysSetting.ProxyHost,
                                     sysSetting.ProxyPort,
                                     sysSetting.ProxyUserName,
                                     sysSetting.ProxyPassword)
        Dim loginError As String = sfdcService.login()
        If Not String.IsNullOrEmpty(loginError) Then
            ' 2-3
            LogFileHelper.writeExecLog(Common.getPrefixOfLogString(String.Format(Constant.ErrMsgLoginFail, sfdcService.LoginUrl)), m_ExecuteLogFileName, False)
            writeConsoleLog(String.Format(Constant.ErrMsgLoginFail, sfdcService.LoginUrl), True)
            Environment.Exit(Constant.ExitCodeError)
        End If
        ' 1-2 ログイン成功
        LogFileHelper.writeExecLog(Common.getPrefixOfLogString(String.Format(Constant.LoginSuccessMsg, sfdcService.LoginUrl)), m_ExecuteLogFileName, False)
        writeConsoleLog(String.Format(Constant.LoginSuccessMsg, sfdcService.LoginUrl), True)
        ' 処理開始時間を Salesforce（.Netログ）に保存
        m_NetLogId = NetLogDAO.createNetLog(DateTime.Now)
    End Sub
#End Region

#Region "2.0 主処理"
    ''' <summary>
    ''' 2.0 主処理。
    ''' 学生一覧情報ファイルを読み込み、Student__c を Upsert（キー：UpdateKey__c）する。
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy Nguyen Ngoc Quy</remarks>
    Private Sub mainProcess()
        ' 2.1 学生一覧情報ファイル読込
        Dim inputFilePath As String = sysSetting.InputFolder & sysSetting.InputFileName
        If Not File.Exists(inputFilePath) Then
            ' 2-4
            LogFileHelper.writeExecLog(Common.getPrefixOfLogString(Constant.ErrMsgInputFileNotFound), m_ExecuteLogFileName, False)
            writeConsoleLog(Constant.ErrMsgInputFileNotFound, True)
            NetLogDAO.updateNetLog(m_NetLogId, DateTime.Now, Constant.NetLogStatusAllFail, 0, 0, 0, 0, Constant.ErrMsgInputFileNotFound)
            Environment.Exit(Constant.ExitCodeError)
        End If
        Dim csvRowList As List(Of String()) = CsvFileHelper.getCsvRowList(inputFilePath)
        Dim studentUpsertList As New List(Of Student__c)
        Dim rowNumList As New List(Of Integer) ' Upsert 対象の CSV 行番号

        ' クラス取得（Name をキー）
        Dim classNameList As List(Of String) = csvRowList.Skip(1) _
            .Where(Function(c) c.Length = ConstantCSV.NumberOfColumnCSV) _
            .Select(Function(c) c(ConstantCSV.Col_ClassName)) _
            .Where(Function(name) Not String.IsNullOrWhiteSpace(name)) _
            .Distinct().ToList()
        Dim classList As List(Of Class__c) = ClassDAO.getClassByName(classNameList)
        ' fieldsToNull 判定用の項目情報
        Dim srcProperties As List(Of PropertyInfo) = StudentDAO.getFieldToNull(Constant.NameObjectStudent, Constant.NamesFieldStudentUpsert)
        ' 2.3 レコードループ（1 行目のヘッダはスキップ）
        For i As Integer = 1 To csvRowList.Count - 1
            Dim csvRow As String() = csvRowList(i)
            Dim noRow As Integer = i + 1
            m_InputCount += 1

            ' 欄数チェック（FORMAT 不正 → 2-5、処理中止）
            If csvRow.Length <> ConstantCSV.NumberOfColumnCSV Then
                LogFileHelper.writeExecLog(Common.getPrefixOfLogString(Constant.ErrMsgInputFileFormat), m_ExecuteLogFileName, False)
                writeConsoleLog(Constant.ErrMsgInputFileFormat, True)
                NetLogDAO.updateNetLog(m_NetLogId, DateTime.Now, Constant.NetLogStatusAllFail, m_InputCount, 0, 0, 0, Constant.ErrMsgInputFileFormat)
                Environment.Exit(Constant.ExitCodeError)
            End If
            ' "NULL" 文字列を空文字に変換
            Common.replaceNullString(csvRow)

            ' 2.4 クラス存在チェック
            Dim className As String = csvRow(ConstantCSV.Col_ClassName)
            Dim classId As String = classList _
                .Where(Function(c) c.Name = className) _
                .Select(Function(c) c.Id).FirstOrDefault()
            If String.IsNullOrEmpty(classId) Then
                ' 2-6 クラスが存在なし → エラーレコード
                Dim msgClassNotExist As String = String.Format(Constant.ErrMsgClassNotExist, className)
                LogFileHelper.writeExecLog(Common.getPrefixOfLogString(msgClassNotExist), m_ExecuteLogFileName, False)
                writeConsoleLog(String.Format(Constant.ErrMsgClassNotExist, className), True)
                m_ErrorMessageList.Add(String.Format("row {0}：{1}", noRow, msgClassNotExist))
                m_InsertNGCount += 1
                Continue For
            End If

            ' Upsert リスト作成
            Dim objStudent As Student__c = StudentDAO.createStudent(csvRow, classId, srcProperties)
            studentUpsertList.Add(objStudent)
            rowNumList.Add(noRow)
        Next

        m_InsertCount = studentUpsertList.Count

        ' Upsert（キー：UpdateKey__c、バッチ分割は SFDCHelper 側で実施）
        If studentUpsertList.Any Then
            Dim upsertResultList As List(Of UpsertResult) = StudentDAO.upsertStudent(studentUpsertList)
            For i As Integer = 0 To upsertResultList.Count - 1
                Dim noCSVRow As Integer = rowNumList(i)
                If upsertResultList(i).success Then
                    m_InsertOKCount += 1
                Else
                    m_InsertNGCount += 1
                    Dim errMsg As String = String.Empty
                    If upsertResultList(i).errors IsNot Nothing AndAlso upsertResultList(i).errors.Length > 0 Then
                        errMsg = upsertResultList(i).errors(0).message
                    End If
                    ' 2-7
                    LogFileHelper.writeExecLog(Common.getPrefixOfLogString(String.Format(Constant.ErrMsgStudentUpsertFail, errMsg)), m_ExecuteLogFileName, False)
                    writeConsoleLog(String.Format(Constant.ErrMsgStudentUpsertFail, errMsg), True)
                    m_ErrorMessageList.Add(String.Format("row {0}：{1}", noCSVRow, errMsg))
                End If
            Next
        End If

        ' 2.5 実行ログ出力（1-3 / 1-4）
        LogFileHelper.writeExecLog(Common.getPrefixOfLogString(String.Format(Constant.StudentGetCountMsg, m_InputCount)), m_ExecuteLogFileName, False)
        LogFileHelper.writeExecLog(Common.getPrefixOfLogString(String.Format(Constant.StudentUpsertCountMsg, m_InsertCount, m_InsertOKCount, m_InsertNGCount)), m_ExecuteLogFileName, False)
        LogFileHelper.writeExecLog(Common.getPrefixOfLogString(String.Format(Constant.StudentGetCommitCountMsg, m_CommitCount)), m_ExecuteLogFileName, False)
        ' Salesforce ステータス判定（終了処理で使用）
        m_ResultStatus = getResultStatus(m_InsertOKCount, m_InsertNGCount)
    End Sub
#End Region

#Region "3.0 終了処理"
    ''' <summary>
    ''' 3.0 終了処理。
    ''' 古いログ削除 → 終了ログ出力 → .Netログ 登録。
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Sub finishProcess()
        ' 3.1 古いログ削除
        LogFileHelper.deleteOldLog(sysSetting.LogFolder, sysSetting.LogDays)
        ' 3.2 終了ログ（1-5、末尾に空行）
        LogFileHelper.writeExecLog(Common.getPrefixOfLogString(Constant.EndProgramMsg), m_ExecuteLogFileName, True)
        ' 3.3 .Netログ 登録
        NetLogDAO.updateNetLog(m_NetLogId, DateTime.Now, m_ResultStatus, m_InputCount, m_InsertCount, m_InsertOKCount, m_InsertNGCount, String.Join(vbCrLf, m_ErrorMessageList))
    End Sub
#End Region

#Region "99.0 例外処理"
    ''' <summary>
    ''' 99.0 例外処理。
    ''' 例外ログ（2-8）出力 → .Netログ を異常終了で更新。
    ''' </summary>
    ''' <param name="ex">発生した例外</param>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Sub exceptionProcess(ByVal ex As Exception)
        ' 2-8 例外発生
        Dim exceptionMessage As String = String.Format(Constant.ErrMsgException, ex.Message)
        Try
            LogFileHelper.writeExecLog(Common.getPrefixOfLogString(exceptionMessage), m_ExecuteLogFileName, False)
            writeConsoleLog(exceptionMessage, True)
        Catch
            ' 実行ログに書けない場合は EXE 隣接に出力
            LogFileHelper.writeLogNextToExe(Common.getPrefixOfLogString(exceptionMessage), m_ExecuteLogFileName)
        End Try

        ' .Netログ を異常終了で更新
        Try
            If Not String.IsNullOrEmpty(m_NetLogId) Then
                NetLogDAO.updateNetLog(m_NetLogId, DateTime.Now, Constant.NetLogStatusAbnormal, m_InputCount, m_InsertCount, m_InsertOKCount, m_InsertNGCount, exceptionMessage)
            End If
        Catch
            ' .Netログ 更新失敗は処理継続
        End Try
    End Sub
#End Region

#Region "補助"
    ''' <summary>
    ''' 二重起動チェック。（同名プロセスが 2 つ以上ある場合は True）
    ''' </summary>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Function isDuplicateProcess() As Boolean
        Dim current As Process = Process.GetCurrentProcess()
        Dim sameProcesses As Process() = Process.GetProcessesByName(current.ProcessName)
        Return sameProcesses.Length > 1
    End Function

    ''' <summary>
    ''' 登録結果からステータスを判定する。
    ''' </summary>
    ''' <param name="okCount">登録成功件数</param>
    ''' <param name="ngCount">登録失敗件数</param>
    ''' <returns>正常終了 / 一部登録失敗 / 全件登録失敗</returns>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Private Function getResultStatus(ByVal okCount As Integer, ByVal ngCount As Integer) As String
        If ngCount = 0 Then
            Return Constant.NetLogStatusSuccess
        End If
        If okCount = 0 Then
            Return Constant.NetLogStatusAllFail
        End If
        Return Constant.NetLogStatusPartialFail
    End Function

    ''' <summary>
    ''' コンソールにログ出力する。
    ''' </summary>
    ''' <param name="message">ログメッセージ</param>
    ''' <param name="isVisible">表示するかどうか</param>
    ''' <remarks>作成日: 2026/07/28 Nguyen Ngoc Quy</remarks>
    Public Shared Sub writeConsoleLog(ByVal message As String, ByVal isVisible As Boolean)
        If isVisible Then
            Console.WriteLine(Common.getPrefixOfLogString(message))
        End If
    End Sub
#End Region

End Class
