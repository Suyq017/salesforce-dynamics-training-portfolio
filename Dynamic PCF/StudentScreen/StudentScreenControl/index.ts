import "../node_modules/@types/powerapps-component-framework/index.d.ts";
import { IInputs, IOutputs } from "./generated/ManifestTypes";
import { IDropdownOption } from "@fluentui/react/lib/Dropdown";

interface DataverseOptionItem {
    Value: number;
    Label?: {
        UserLocalizedLabel?: {
            Label: string;
        };
    };
}
 
interface DataverseOptionSetResponse {
    OptionSet?: {
        Options?: DataverseOptionItem[];
    };
}

export class StudentScreenControl implements ComponentFramework.StandardControl<
  IInputs,
  IOutputs
> {
  private _container: HTMLDivElement;
  private _searchInput: HTMLInputElement;
  private _rowCountContainer: HTMLDivElement;
  private _pageInfoContainer: HTMLDivElement;
  private _recordCountContainer: HTMLDivElement;
  private _pageSizeSelect: HTMLSelectElement;
  private _paginationContainer: HTMLDivElement;
  private _tableFooter: HTMLDivElement;
  private _headerBar: HTMLDivElement;
  private _footerActions: HTMLDivElement;
  private _pageNumberInput: HTMLInputElement;

  private _context: ComponentFramework.Context<IInputs>;
  private _currentPage = 1;
  private _pageSize = 5;
  private _sortedColumn: string | null = null;
  private _sortOrder: "asc" | "desc" = "asc";

  public init(
    context: ComponentFramework.Context<IInputs>,
    notifyOutputChanged: () => void,
    state: ComponentFramework.Dictionary,
    container: HTMLDivElement,
  ): void {
    this._container = container;
    this._context = context;

    const modalHost = document.createElement("div");
    const modal = document.createElement("div");
    modal.id = "myModal";
    modal.classList.add("modal");
    modal.style.display = "none";

    const modalContent = document.createElement("div");
    modalContent.classList.add("modal-content");

    const closeButton = document.createElement("span");
    closeButton.classList.add("close");
    closeButton.textContent = "x";

    const modalText = document.createElement("p");
    modalText.textContent = "Some text in the Modal..";

    modalContent.appendChild(closeButton);
    modalContent.appendChild(modalText);
    modal.appendChild(modalContent);

    modalHost.appendChild(modal);
    this._container.appendChild(modalHost);

    if (closeButton && modal) {
      closeButton.addEventListener("click", () => {
        modal.style.display = "none";
      });
    }

    if (modal) {
      window.addEventListener("click", (event) => {
        if (event.target === modal) {
          modal.style.display = "none";
        }
      });
    }

    // Search input
    this._searchInput = document.createElement("input");
    this._searchInput.setAttribute("type", "text");
    this._searchInput.setAttribute("placeholder", "Search...");
    this._searchInput.classList.add("search-input");
    this._searchInput.addEventListener("input", () => {
      this._currentPage = 1;
      this.updateTable();
    });

    // Create button
    const createButton = document.createElement("button");
    createButton.textContent = "Create";
    createButton.classList.add("action-button");
    createButton.addEventListener("click", () => {
      void this.openModal("Create", new Map());
    });

    this._headerBar = document.createElement("div");
    this._headerBar.classList.add("header-bar");
    this._headerBar.appendChild(this._searchInput);
    this._headerBar.appendChild(createButton);
    this._container.appendChild(this._headerBar);

    // Row count display
    this._rowCountContainer = document.createElement("div");
    this._rowCountContainer.classList.add("row-count");

    this._pageInfoContainer = document.createElement("div");
    this._pageInfoContainer.classList.add("page-info");

    this._recordCountContainer = document.createElement("div");
    this._recordCountContainer.classList.add("record-count");

    this._rowCountContainer.appendChild(this._pageInfoContainer);
    this._rowCountContainer.appendChild(this._recordCountContainer);

    // Page size dropdown
    this._pageSizeSelect = document.createElement("select");
    this._pageSizeSelect.classList.add("select-dropdown");
    [5, 10, 15, 20].forEach((size) => {
      const option = document.createElement("option");
      option.value = size.toString();
      option.textContent = `${size} per page`;
      this._pageSizeSelect.appendChild(option);
    });

    this._pageSizeSelect.value = this._pageSize.toString();
    this._pageSizeSelect.addEventListener("change", () => {
      this._pageSize = parseInt(this._pageSizeSelect.value, 10);
      this._currentPage = 1;
      this.updateTable();
    });

    this._footerActions = document.createElement("div");
    this._footerActions.classList.add("footer-actions");
    this._footerActions.appendChild(this._pageSizeSelect);

    // Pagination container
    this._paginationContainer = document.createElement("div");
    this._paginationContainer.classList.add("pagination");

    this._pageNumberInput = document.createElement("input");
    this._pageNumberInput.type = "number";
    this._pageNumberInput.classList.add("page-number-input");
    this._pageNumberInput.min = "1";
    this._pageNumberInput.step = "1";

    this._tableFooter = document.createElement("div");
    this._tableFooter.classList.add("table-footer");
    this._tableFooter.appendChild(this._rowCountContainer);
    this._tableFooter.appendChild(this._footerActions);
    this._tableFooter.appendChild(this._paginationContainer);
  }

  public updateView(context: ComponentFramework.Context<IInputs>): void {
    this._context = context;
    this.updateTable();
  }

  private updateTable(): void {
    const searchQuery = this._searchInput.value.trim().toLowerCase();
    let table = this._container.querySelector("table") as HTMLTableElement;
    let tbody = this._container.querySelector(
      "tbody",
    ) as HTMLTableSectionElement;
    let thead = this._container.querySelector(
      "thead",
    ) as HTMLTableSectionElement;

    if (!table) {
      table = document.createElement("table");
      thead = document.createElement("thead");
      tbody = document.createElement("tbody");

      const trHead = document.createElement("tr");
      this._context.parameters.studentList.columns.forEach((columnItem) => {
        const th = document.createElement("th");
        th.textContent = columnItem.displayName;
        th.classList.add("sortable");
        th.dataset.column = columnItem.name;

        th.addEventListener("click", () =>
          this.handleSort(columnItem.name, th),
        );

        trHead.appendChild(th);
      });

      const actionHeader = document.createElement("th");
      actionHeader.textContent = "Actions";
      trHead.appendChild(actionHeader);

      thead.appendChild(trHead);
      table.appendChild(thead);
      table.appendChild(tbody);
      this._container.appendChild(table);
    } else {
      tbody.innerHTML = "";
    }

    this._container.appendChild(this._tableFooter);

    this.populateTableRows(tbody, searchQuery);
  }

  private handleSort(columnName: string, thElement: HTMLElement): void {
    if (this._sortedColumn === columnName) {
      this._sortOrder = this._sortOrder === "asc" ? "desc" : "asc";
    } else {
      this._sortedColumn = columnName;
      this._sortOrder = "asc";
    }

    // Update UI indicators
    document
      .querySelectorAll("th.sortable")
      .forEach((th) => th.classList.remove("active"));
    thElement.classList.add("active");
    thElement.dataset.order = this._sortOrder;

    this.updateTable();
  }

  private populateTableRows(
    tbody: HTMLTableSectionElement,
    searchQuery: string,
  ): void {
    const { studentList } = this._context.parameters;
    const filteredRecords = studentList.sortedRecordIds.filter((recordId) =>
      studentList.columns.some((columnItem) =>
        String(studentList.records[recordId].getFormattedValue(columnItem.name) ?? "")
          .toLowerCase()
          .includes(searchQuery),
      ),
    );

    // Apply sorting
    if (this._sortedColumn) {
      filteredRecords.sort((a, b) => {
        const aValue =
          studentList.records[a].getFormattedValue(this._sortedColumn!) || "";
        const bValue =
          studentList.records[b].getFormattedValue(this._sortedColumn!) || "";

        if (this._sortOrder === "asc") {
          return aValue.localeCompare(bValue, undefined, { numeric: true });
        } else {
          return bValue.localeCompare(aValue, undefined, { numeric: true });
        }
      });
    }

    const totalPages = Math.ceil(filteredRecords.length / this._pageSize);
    const startIdx = (this._currentPage - 1) * this._pageSize;
    const paginatedRecords = filteredRecords.slice(
      startIdx,
      startIdx + this._pageSize,
    );

    const fragment = document.createDocumentFragment();

    paginatedRecords.forEach((recordId) => {
      const tr = document.createElement("tr");
      this._context.parameters.studentList.columns.forEach((columnItem) => {
        const td = document.createElement("td");
        td.textContent = this._context.parameters.studentList.records[
          recordId
        ].getFormattedValue(columnItem.name);
        tr.appendChild(td);
      });

      const actionsCell = document.createElement("td");
      actionsCell.classList.add("row-actions-cell");

      const createRowButton = (label: string, onClick: () => void) => {
        const button = document.createElement("button");
        button.type = "button";
        button.textContent = label;
        button.classList.add("row-action-button");
        button.addEventListener("click", onClick);
        return button;
      };

      const actionsWrap = document.createElement("div");
      actionsWrap.classList.add("row-actions");
      actionsWrap.appendChild(
        createRowButton("Details", () => this.openRecordModal("Details", recordId)),
      );
      actionsWrap.appendChild(
        createRowButton("Update", () => this.openRecordModal("Update", recordId)),
      );
      actionsWrap.appendChild(
        createRowButton("Delete", () => this.openRecordModal("Delete", recordId)),
      );

      actionsCell.appendChild(actionsWrap);
      tr.appendChild(actionsCell);

      fragment.appendChild(tr);
    });

    tbody.appendChild(fragment);
    this._pageInfoContainer.textContent = `Page ${this._currentPage} of ${totalPages}`;
    this._recordCountContainer.textContent = `Showing ${paginatedRecords.length} of ${filteredRecords.length} records`;

    this.updatePaginationControls(totalPages);
  }

  private updatePaginationControls(totalPages: number): void {
    this._paginationContainer.innerHTML = "";

    this._pageNumberInput.value = String(this._currentPage);
    this._pageNumberInput.max = String(totalPages);

    this._pageNumberInput.onchange = () => {
      const requestedPage = parseInt(this._pageNumberInput.value, 10);
      if (Number.isNaN(requestedPage)) {
        this._pageNumberInput.value = String(this._currentPage);
        return;
      }

      const clampedPage = Math.min(Math.max(requestedPage, 1), totalPages);
      this._currentPage = clampedPage;
      this.updateTable();
    };

    this._pageNumberInput.onkeydown = (event) => {
      if (event.key === "Enter") {
        this._pageNumberInput.blur();
      }
    };

    const pageInputWrap = document.createElement("div");
    pageInputWrap.classList.add("page-input-wrap");
    pageInputWrap.appendChild(this._pageNumberInput);

    const createPageButton = (
      text: string,
      action: () => void,
      disabled: boolean,
    ) => {
      const button = document.createElement("button");
      button.textContent = text;
      button.classList.add("pagination-button");
      if (disabled) button.classList.add("disabled");
      button.addEventListener("click", action);
      return button;
    };

    // Create navigation buttons
    this._paginationContainer.appendChild(
      createPageButton(
        "<<",
        () => {
          if (this._currentPage !== 1) {
            this._currentPage = 1;
            this.updateTable();
          }
        },
        this._currentPage === 1,
      ),
    );

    this._paginationContainer.appendChild(
      createPageButton(
        "<",
        () => {
          if (this._currentPage > 1) {
            this._currentPage--;
            this.updateTable();
          }
        },
        this._currentPage === 1,
      ),
    );

    this._paginationContainer.appendChild(pageInputWrap);

    this._paginationContainer.appendChild(
      createPageButton(
        ">",
        () => {
          if (this._currentPage < totalPages) {
            this._currentPage++;
            this.updateTable();
          }
        },
        this._currentPage === totalPages,
      ),
    );

    this._paginationContainer.appendChild(
      createPageButton(
        ">>",
        () => {
          if (this._currentPage !== totalPages) {
            this._currentPage = totalPages;
            this.updateTable();
          }
        },
        this._currentPage === totalPages,
      ),
    );
  }

  private openRecordModal(actionTitle: string, recordId: string): void {
    const details = this.getRecordDetailLines(recordId);
    void this.openModal(actionTitle, details.size ? details : new Map([["No record selected.", ""]]));
  }

  private getRecordDetailLines(recordId: string): Map<string, string> {
    const record = this._context.parameters.studentList.records[recordId];
    if (!record) {
      return new Map();
    }

    const detailLines = new Map();
    detailLines.set("Id", recordId);
    this._context.parameters.studentList.columns.forEach((col) => {
      detailLines.set(col.displayName, record.getFormattedValue(col.name));
    });
    return detailLines;
  }

  private async openModal(titleText: string, lines: Map<string, string>): Promise<void> {
    const modal = this._container.querySelector("#myModal") as HTMLDivElement | null;
    if (!modal) {
      return;
    }

    const modalContent = modal.querySelector(".modal-content") as HTMLDivElement | null;
    if (!modalContent) {
      return;
    }
    modalContent.innerHTML = "";

    const closeButton = document.createElement("span");
    closeButton.classList.add("close");
    closeButton.textContent = "x";
    closeButton.addEventListener("click", () => {
      modal.style.display = "none";
    });

    const title = document.createElement("p");
    title.textContent = titleText;
    title.classList.add("modal-title");

    modalContent.appendChild(closeButton);
    modalContent.appendChild(title);

    if (titleText === "Details"){
      const contentDiv = document.createElement("div");
      contentDiv.classList.add("modal-body-content");
      lines.forEach((value, key) => {
        if (key === "Id") return;
        const fieldLabel = document.createElement("strong");
        fieldLabel.textContent = key;

        fieldLabel.appendChild(document.createElement("br"));

        const fieldValue = document.createElement("span");
        fieldValue.textContent = value;
        const lineDiv = document.createElement("div");
        lineDiv.appendChild(fieldLabel);
        lineDiv.appendChild(fieldValue);
        contentDiv.appendChild(lineDiv);

        contentDiv.appendChild(document.createElement("br"));
      });
      modalContent.appendChild(contentDiv);
    }

    if (titleText === "Create"){
      const contentDiv = document.createElement("div");
      contentDiv.classList.add("modal-body-content");

      const createForm = document.createElement("form");

      const fullNameLabel = document.createElement("strong");
      fullNameLabel.textContent = "Full Name";
      createForm.appendChild(fullNameLabel);
      createForm.appendChild(document.createElement("br"));
      const fullNameField = document.createElement("input");
      fullNameField.type = "text";
      fullNameField.placeholder = "Full Name";
      fullNameField.required = true;
      createForm.appendChild(fullNameField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const classList = await this.getClassList();
      const classLabel = document.createElement("strong");
      classLabel.textContent = "Class";
      createForm.appendChild(classLabel);
      createForm.appendChild(document.createElement("br"));
      const classField = document.createElement("select");
      classField.required = true;
      classList.forEach((classCode: string, classId: string) => {
        const option = document.createElement("option");
        option.value = classId;
        option.textContent = classCode;
        classField.appendChild(option);
      });
      createForm.appendChild(classField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const learningStatusList = await this.loadOptionSetMetadata("ksvc_opt_learningstatus");
      const learningStatusLabel = document.createElement("strong");
      learningStatusLabel.textContent = "Learning Status";
      createForm.appendChild(learningStatusLabel);
      createForm.appendChild(document.createElement("br"));
      const learningStatusField = document.createElement("select");
      learningStatusField.required = true;
      learningStatusList.forEach((option: IDropdownOption) => {
        const opt = document.createElement("option");
        opt.value = String(option.key);
        opt.textContent = option.text;
        learningStatusField.appendChild(opt);
      });
      createForm.appendChild(learningStatusField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const genderList = await this.loadOptionSetMetadata("ksvc_opt_gender");
      const genderLabel = document.createElement("strong");
      genderLabel.textContent = "Gender";
      createForm.appendChild(genderLabel);
      createForm.appendChild(document.createElement("br"));
      const genderField = document.createElement("select");
      genderList.forEach((option: IDropdownOption) => {
        const opt = document.createElement("option");
        opt.value = String(option.key);
        opt.textContent = option.text;
        genderField.appendChild(opt);
      });
      createForm.appendChild(genderField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const totalCreditLabel = document.createElement("strong");
      totalCreditLabel.textContent = "Total Credit";
      createForm.appendChild(totalCreditLabel);
      createForm.appendChild(document.createElement("br"));
      const totalCreditField = document.createElement("input");
      totalCreditField.type = "number";
      totalCreditField.placeholder = "Total Credit";
      createForm.appendChild(totalCreditField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const gpaScoreLabel = document.createElement("strong");
      gpaScoreLabel.textContent = "GPA Score";
      createForm.appendChild(gpaScoreLabel);
      createForm.appendChild(document.createElement("br"));
      const gpaScoreField = document.createElement("input");
      gpaScoreField.type = "number";
      gpaScoreField.placeholder = "GPA Score";
      createForm.appendChild(gpaScoreField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const birthdayLabel = document.createElement("strong");
      birthdayLabel.textContent = "Birthday";
      createForm.appendChild(birthdayLabel);
      createForm.appendChild(document.createElement("br"));
      const birthdayField = document.createElement("input");
      birthdayField.type = "date";
      createForm.appendChild(birthdayField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const classificationList = await this.loadOptionSetMetadata("ksvc_opt_classification");
      const classificationLabel = document.createElement("strong");
      classificationLabel.textContent = "Classification";
      createForm.appendChild(classificationLabel);
      createForm.appendChild(document.createElement("br"));
      const classificationField = document.createElement("select");
      classificationList.forEach((option: IDropdownOption) => {
        const opt = document.createElement("option");
        opt.value = String(option.key);
        opt.textContent = option.text;
        classificationField.appendChild(opt);
      });
      createForm.appendChild(classificationField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      contentDiv.appendChild(createForm);
      modalContent.appendChild(contentDiv);

      const createButton = document.createElement("button");
      createButton.textContent = "save";
      createButton.classList.add("save-button");
      modalContent.appendChild(createButton);

      createButton.addEventListener("click", () => {
        this._context.webAPI.createRecord("ksvc_tra_student", {
          "ksvc_slt_studentname": fullNameField.value.length > 0 ? fullNameField.value : null,
          "ksvc_lup_class@odata.bind": classField.value.length > 0 ? `/ksvc_mst_classes(${classField.value})` : null,
          "ksvc_opt_learningstatus": learningStatusField.value.length > 0 ? parseInt(learningStatusField.value, 10) : null,
          "ksvc_opt_gender": genderField.value.length > 0 ? parseInt(genderField.value, 10) : null,
          "ksvc_int_toltalcredit": totalCreditField.value.length > 0 ? parseFloat(totalCreditField.value) : null,
          "ksvc_dcn_gpascore": gpaScoreField.value.length > 0 ? parseFloat(gpaScoreField.value) : null,
          "ksvc_dat_birthday": birthdayField.value.length > 0 ? new Date(birthdayField.value) : null,
          "ksvc_opt_classification": classificationField.value.length > 0 ? parseInt(classificationField.value, 10) : null,
        }).then(() => {
          modal.style.display = "none";
          this._context.parameters.studentList.refresh();
          return;
        }).catch((error) => {
          console.error("Error creating record:", error);
          return;
        });
      });
    }

    if (titleText === "Update"){
      const contentDiv = document.createElement("div");
      contentDiv.classList.add("modal-body-content");

      const createForm = document.createElement("form");

      const fullNameLabel = document.createElement("strong");
      fullNameLabel.textContent = "Full Name";
      createForm.appendChild(fullNameLabel);
      createForm.appendChild(document.createElement("br"));
      const fullNameField = document.createElement("input");
      fullNameField.type = "text";
      fullNameField.placeholder = "Full Name";
      fullNameField.required = true;
      fullNameField.value = lines.get("Full Name") || "";
      createForm.appendChild(fullNameField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const classList = await this.getClassList();
      const classLabel = document.createElement("strong");
      classLabel.textContent = "Class";
      createForm.appendChild(classLabel);
      createForm.appendChild(document.createElement("br"));
      const classField = document.createElement("select");
      classList.forEach((classCode: string, classId: string) => {
        const option = document.createElement("option");
        option.value = classId;
        option.textContent = classCode;
        if (option.textContent === lines.get("Class")) {
          option.selected = true;
        }
        classField.appendChild(option);
      });
      createForm.appendChild(classField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const learningStatusList = await this.loadOptionSetMetadata("ksvc_opt_learningstatus");
      const learningStatusLabel = document.createElement("strong");
      learningStatusLabel.textContent = "Learning Status";
      createForm.appendChild(learningStatusLabel);
      createForm.appendChild(document.createElement("br"));
      const learningStatusField = document.createElement("select");
      learningStatusList.forEach((option: IDropdownOption) => {
        const opt = document.createElement("option");
        opt.value = String(option.key);
        opt.textContent = option.text;
        if (opt.textContent === lines.get("Learning Status")) {
          opt.selected = true;
        }
        learningStatusField.appendChild(opt);
      });
      createForm.appendChild(learningStatusField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const genderList = await this.loadOptionSetMetadata("ksvc_opt_gender");
      const genderLabel = document.createElement("strong");
      genderLabel.textContent = "Gender";
      createForm.appendChild(genderLabel);
      createForm.appendChild(document.createElement("br"));
      const genderField = document.createElement("select");
      genderList.forEach((option: IDropdownOption) => {
        const opt = document.createElement("option");
        opt.value = String(option.key);
        opt.textContent = option.text;
        if (opt.textContent === lines.get("Gender")) {
          opt.selected = true;
        }
        genderField.appendChild(opt);
      });
      createForm.appendChild(genderField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const totalCreditLabel = document.createElement("strong");
      totalCreditLabel.textContent = "Total Credit";
      createForm.appendChild(totalCreditLabel);
      createForm.appendChild(document.createElement("br"));
      const totalCreditField = document.createElement("input");
      totalCreditField.type = "number";
      totalCreditField.placeholder = "Total Credit";
      totalCreditField.required = true;
      if (lines.get("Total Credit")?.length) {
        totalCreditField.value = parseFloat(lines.get("Total Credit") || "0").toString();
      }
      createForm.appendChild(totalCreditField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const gpaScoreLabel = document.createElement("strong");
      gpaScoreLabel.textContent = "GPA Score";
      createForm.appendChild(gpaScoreLabel);
      createForm.appendChild(document.createElement("br"));
      const gpaScoreField = document.createElement("input");
      gpaScoreField.type = "number";
      gpaScoreField.placeholder = "GPA Score";
      gpaScoreField.required = true;
      if (lines.get("GPA Score")?.length) {
        gpaScoreField.value = (parseFloat(lines.get("GPA Score") || "0") || 0).toString();
      }
      createForm.appendChild(gpaScoreField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const birthdayLabel = document.createElement("strong");
      birthdayLabel.textContent = "Birthday";
      createForm.appendChild(birthdayLabel);
      createForm.appendChild(document.createElement("br"));
      const birthdayField = document.createElement("input");
      birthdayField.type = "date";
      birthdayField.required = true;
      const dateValue = lines.get("Birthday")?.split("/") || [];
      if (dateValue.length > 0) {
        birthdayField.value = new Date(Number(dateValue?.[2]), Number(dateValue?.[1]) - 1, Number(dateValue?.[0])).toISOString().split("T")[0];
      }
      createForm.appendChild(birthdayField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      const classificationList = await this.loadOptionSetMetadata("ksvc_opt_classification");
      const classificationLabel = document.createElement("strong");
      classificationLabel.textContent = "Classification";
      createForm.appendChild(classificationLabel);
      createForm.appendChild(document.createElement("br"));
      const classificationField = document.createElement("select");
      classificationList.forEach((option: IDropdownOption) => {
        const opt = document.createElement("option");
        opt.value = String(option.key);
        opt.textContent = option.text;
        if (opt.textContent === lines.get("Classification")) {
          opt.selected = true;
        }
        classificationField.appendChild(opt);
      });
      createForm.appendChild(classificationField);
      createForm.appendChild(document.createElement("br"));
      createForm.appendChild(document.createElement("br"));

      contentDiv.appendChild(createForm);
      modalContent.appendChild(contentDiv);

      const updateButton = document.createElement("button");
      updateButton.textContent = "Save";
      updateButton.classList.add("save-button");
      modalContent.appendChild(updateButton);

      updateButton.addEventListener("click", () => {
        const recordId = lines.get("Id");
        if (!recordId) {
          return;
        }
        this._context.webAPI.updateRecord("ksvc_tra_student", recordId, {
          "ksvc_slt_studentname": fullNameField.value.length > 0 ? fullNameField.value : null,
          "ksvc_lup_class@odata.bind": classField.value.length > 0 ? `/ksvc_mst_classes(${classField.value})` : null,
          "ksvc_opt_learningstatus": learningStatusField.value.length > 0 ? parseInt(learningStatusField.value, 10) : null,
          "ksvc_opt_gender": genderField.value.length > 0 ? parseInt(genderField.value, 10) : null,
          "ksvc_int_toltalcredit": totalCreditField.value.length > 0 ? parseFloat(totalCreditField.value) : null,
          "ksvc_dcn_gpascore": gpaScoreField.value.length > 0 ? parseFloat(gpaScoreField.value) : null,
          "ksvc_dat_birthday": birthdayField.value.length > 0 ? new Date(birthdayField.value) : null,
          "ksvc_opt_classification": classificationField.value.length > 0 ? parseInt(classificationField.value, 10) : null,
        }).then(() => {
          modal.style.display = "none";
          this._context.parameters.studentList.refresh();
          return;
        }).catch((error) => {
          console.error("Error updating record:", error);
          return;
        });
      });   
    }

    if (titleText === "Delete"){
      const deleteMessage = document.createElement("p");
      deleteMessage.textContent = "Are you sure you want to delete this record?";
      modalContent.appendChild(deleteMessage);

      const deleteButton = document.createElement("button");
      deleteButton.textContent = "Delete";
      deleteButton.classList.add("delete-button");
      modalContent.appendChild(deleteButton);
      deleteButton.addEventListener("click", () => {
        const recordId = lines.get("Id");
        if (!recordId) {
          return;
        }
        this._context.webAPI.deleteRecord("ksvc_tra_student", recordId).then(() => {
          modal.style.display = "none";
          this._context.parameters.studentList.refresh();
          return;
        }).catch((error) => {
          console.error("Error deleting record:", error);
          return;
        });
      });
    }
    modal.style.display = "block";
  }

  public getOutputs(): IOutputs {
    return {};
  }

  public destroy(): void {
    return;
  }

  private async getClassList(): Promise<Map<string, string>> {
    const classList = new Map<string, string>();
    const response = await this._context.webAPI.retrieveMultipleRecords("ksvc_mst_class");
    response.entities.forEach((entity) => {
      classList.set(entity.ksvc_mst_classid, entity.ksvc_slt_classcode);
    });
    return classList;
  }

  private async loadOptionSetMetadata(attributeName: string): Promise<IDropdownOption[]> {
        const query = `EntityDefinitions(LogicalName='ksvc_tra_student')/Attributes(LogicalName='${attributeName}')/Microsoft.Dynamics.CRM.PicklistAttributeMetadata?$select=LogicalName&$expand=OptionSet($select=Options)`;
 
        try {
            const response = await fetch(`/api/data/v9.2/${query}`, {
                method: "GET",
                headers: {
                    "OData-MaxVersion": "4.0",
                    "OData-Version": "4.0",
                    "Content-Type": "application/json; charset=utf-8",
                    Accept: "application/json",
                },
            });
 
            if (response.ok) {
                const data = (await response.json()) as DataverseOptionSetResponse;
                const options = data.OptionSet?.Options || [];
 
                return options.map((opt) => ({
                    key: opt.Value,
                    text: opt.Label?.UserLocalizedLabel?.Label || String(opt.Value),
                }));
            }
        } catch (error) {
            console.warn(`Không lấy được options của ${attributeName}:`, error);
        }
        return [];
    }
}