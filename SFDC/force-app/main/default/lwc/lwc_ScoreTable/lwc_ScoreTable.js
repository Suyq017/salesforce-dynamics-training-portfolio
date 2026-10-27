/**
 * lwc_ScoreTable.js
 * 学習成果を表示するためのLWCコンポーネントのJavaScriptファイルです。
 * @created 2026/06/24 Nguyen Ngoc Quy
 * @modified 2026/07/20 Nguyen Ngoc Quy
 */
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import fetchSubjectScoresBySemester from '@salesforce/apex/LWC_DetailStudentCtrl.fetchSubjectScoresBySemester';
// 2026/07/20 Nguyen Ngoc Quy Add Start
import { NavigationMixin } from 'lightning/navigation';
// 2026/07/20 Nguyen Ngoc Quy Add End

// 2026/07/20 Nguyen Ngoc Quy Modify Start
// export default class Lwc_ScoreTable extends LightningElement {
export default class Lwc_ScoreTable extends NavigationMixin(LightningElement) {
// 2026/07/20 Nguyen Ngoc Quy Modify End

    // 2026/07/13 Nguyen Ngoc Quy Add Start
    UNKNOWN_ERROR_MESSAGE = '成績情報の取得に失敗しました。';
    // 2026/07/13 Nguyen Ngoc Quy Add End

    @api studentId;
    @api totalCredit;
    @api gpaScore;
    
    hasScoreData = false;

    semestersOptionsCombobox = [];

    semestersList = [];
    semestersListShown = [];
    showMoreSemestersDataButton = false;

    selectedSemester = [];

    /**
     * connectedCallback
     * コンポーネントがDOMに挿入されたときに呼び出されるライフサイクルフックです。
     * @param なし
     * @return なし
     * @created 2026/06/24 Nguyen Ngoc Quy
     */
    async connectedCallback() {
        await this.initData();
    }

    /**
     * initData
     * コンポーネントの初期データを取得します。
     * @param studentId 学生ID
     * @return なし
     * @created 2026/06/24 Nguyen Ngoc Quy
     * @modified 2026/07/14 Nguyen Ngoc Quy
     */
    async initData() {
        try {
            let semestersList = await fetchSubjectScoresBySemester({ studentId: this.studentId });
            if (Object.keys(semestersList).length > 0) {
                this.hasScoreData = true;

                this.semestersOptionsCombobox.push({ 
                    label: '全て', 
                    value: 'All' 
                });

                for (const s of Object.values(semestersList)) {
                    this.semestersOptionsCombobox.push({ 
                        label: s.Name, 
                        value: s.Id 
                    });
                }
                this.semestersList = Object.values(semestersList).map(semester => {
                    return {
                        ...semester,
                        totalSemesterCredit: semester.SubjectScores__r.reduce((total, subject) => total + (subject.Subject_look__r.CourseCredit__c || 0), 0),
                        totalScore: semester.SubjectScores__r.reduce((total, subject) => total + (subject.AverageScore__c || 0) * (subject.Subject_look__r.CourseCredit__c || 0), 0),
                        SubjectScores__r: semester.SubjectScores__r.map(subject => {
                            let averageScoreStyleClass;
                            if (subject.Status__c == 'Not Passed') {
                                averageScoreStyleClass = 'slds-text-align_center failScore';
                            } else if (subject.Status__c == 'Passed') {
                                averageScoreStyleClass = 'slds-text-align_center';
                            }
                            let progressScore = null;
                            let practicalScore = null;
                            let midtermScore = null;
                            let finalScore = null;
                            if (subject.Score__r) {
                                for (const score of subject.Score__r) {
                                    switch(score.ExamType__c) {
                                        case 'Progress':
                                            progressScore = score.Score__c;
                                            break;
                                        case 'Practical':
                                            practicalScore = score.Score__c;
                                            break;
                                        case 'Midterm Exam':
                                            midtermScore = score.Score__c;
                                            break;
                                        case 'FinalTerm Exam':
                                            finalScore = score.Score__c;
                                            break;
                                    }
                                }
                            }
                            return {
                                ...subject,
                                averageScoreStyleClass: averageScoreStyleClass,
                                progressScore: progressScore,
                                practicalScore: practicalScore,
                                midtermScore: midtermScore,
                                finalScore: finalScore,
                            };
                        })
                    };
                });
                this.semestersList = this.semestersList.map(semester => {
                    // 2026/07/14 Nguyen Ngoc Quy Modified Start
                    // const averageScore = semester.totalSemesterCredit > 0 ? (semester.totalScore / semester.totalSemesterCredit).toFixed(2) : 'N/A';
                    const averageScore = semester.totalSemesterCredit > 0 ? (semester.totalScore / semester.totalSemesterCredit).toFixed(2) : 0;
                    // 2026/07/14 Nguyen Ngoc Quy Modified End
                    let rank = 'N/A';
                    if (averageScore){
                        if (parseFloat(averageScore) >= 9 && parseFloat(averageScore) <= 10) {
                            rank = 'S';
                        } else if (parseFloat(averageScore) >= 8 && parseFloat(averageScore) <= 8.99) {
                            rank = 'A';
                        } else if (parseFloat(averageScore) >= 7 && parseFloat(averageScore) <= 7.99) {
                            rank = 'B';
                        } else if (parseFloat(averageScore) >= 6 && parseFloat(averageScore) <= 6.99) {
                            rank = 'C';
                        } else if (parseFloat(averageScore) >= 5 && parseFloat(averageScore) <= 5.99) {
                            rank = 'D';
                        } else if (parseFloat(averageScore) >= 0 && parseFloat(averageScore) <= 4.99) {
                            rank = 'F';
                        }
                    }
                    return {
                        ...semester,
                        averageScore: averageScore,
                        rank : rank
                    };
                });
                this.caculateSemesterShown();
            }
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '成績情報の取得に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }
    
    /**
     * getter gpaScoreDisplay
     * GPAスコアの表示用文字列を取得します。
     * @param なし
     * @return なし
     * @created 2026/06/25 Nguyen Ngoc Quy
     * @modified 2026/07/14 Nguyen Ngoc Quy
     */
    get gpaScoreDisplay() {
        // 2026/07/14 Nguyen Ngoc Quy Modified Start
        // return this.gpaScore ? String(this.gpaScore) : 'N/A';
        return this.gpaScore ? this.gpaScore : 0;
        // 2026/07/14 Nguyen Ngoc Quy Modified End
    }
    
    /**
     * getter totalCreditDisplay
     * totalCreditの表示用文字列を取得します。
     * @param なし
     * @return なし
     * @created 2026/06/25 Nguyen Ngoc Quy
     * @modified 2026/07/14 Nguyen Ngoc Quy
     */
    get totalCreditDisplay() {
        // 2026/07/14 Nguyen Ngoc Quy Modified Start
        // return this.totalCredit ? String(this.totalCredit) : 'N/A';
        return this.totalCredit ? this.totalCredit : 0;
        // 2026/07/14 Nguyen Ngoc Quy Modified End
    }

    /**
     * showToast
     * トーストメッセージを表示します。
     * @param title タイトル, message メッセージ, variant 種類
     * @return なし
     * @created 2026/06/24 Nguyen Ngoc Quy
     */
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }

    /**
     * handleLoadMoreSemesterData
     * さらに多くの学期データを読み込みます。
     * @param なし
     * @return なし
     * @created 2026/06/25 Nguyen Ngoc Quy
     */
    handleLoadMoreSemesterData() {
        if (this.semestersList.length > this.semestersListShown.length + 4) {
            this.semestersListShown = this.semestersList.slice(0, this.semestersListShown.length + 4);
            this.showMoreSemestersDataButton = true;
        }
        else {
            this.semestersListShown = this.semestersList;
            this.showMoreSemestersDataButton = false;
        }
    }

    /**
     * caculateSemesterShown
     * 表示する学期データを計算します。
     * @param なし
     * @return なし
     * @created 2026/06/25 Nguyen Ngoc Quy
     */
    caculateSemesterShown() {
         if (this.semestersList.length > 4) {
                    this.semestersListShown = this.semestersList.slice(0, 4);
                    this.showMoreSemestersDataButton = true;
        } else {
            this.semestersListShown = this.semestersList;
        }
    }

    /**
     * handleSemesterChange
     * 学期の選択が変更されたときに呼び出されるハンドラです。
     * @param event 選択変更イベント
     * @return なし
     * @created 2026/06/25 Nguyen Ngoc Quy
     */
    handleSemesterChange(event) {
        const selectedValue = event.target.value;
        if (selectedValue === 'All') {
            this.caculateSemesterShown();
            if (this.semestersList.length > 4) {
                this.showMoreSemestersDataButton = true;
            } else {
                this.showMoreSemestersDataButton = false;
            }
        }
        else {
            this.showMoreSemestersDataButton = false;
            const selectedSemester = this.semestersList.find(semester => semester.Id === selectedValue);
            this.semestersListShown = selectedSemester ? [selectedSemester] : [];
        }
    }

    // 2026/07/20 Nguyen Ngoc Quy Add Start
    handleOpenPDF() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/VF_DetailStudentPDFRender?id=' + this.studentId
            }
        }).then(url => {
            console.log('Generated URL:', url);
            window.open(url, "_blank");
        });
    }
    // 2026/07/20 Nguyen Ngoc Quy Add End
}