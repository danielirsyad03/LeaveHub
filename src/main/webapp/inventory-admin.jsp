<%! private static String inventoryCss() { return "\n\n/* =========================================================\n   PAGE\n   ========================================================= */\n\n* {\n    box-sizing: border-box;\n}\n\n.inventory-page {\n    width: 100%;\n    max-width: 1450px;\n    color: #3f4857;\n    font-size: 13px;\n}\n\n.inventory-page button,\n.inventory-page input,\n.inventory-page select,\n.inventory-page textarea {\n    font-family: inherit;\n}\n\n\n/* =========================================================\n   PAGE HEADER\n   ========================================================= */\n\n.inventory-page-header {\n    display: flex;\n    align-items: flex-start;\n    justify-content: space-between;\n    gap: 20px;\n    margin-bottom: 20px;\n}\n\n.inventory-page-header h1 {\n    margin: 0 0 5px;\n    color: #202938;\n    font-size: 24px;\n    line-height: 1.25;\n    font-weight: 650;\n}\n\n.inventory-page-header p {\n    margin: 0;\n    color: #87909e;\n    font-size: 13px;\n    font-weight: 400;\n}\n\n\n/* =========================================================\n   MESSAGE\n   ========================================================= */\n\n.inventory-message {\n    margin-bottom: 16px;\n    padding: 11px 14px;\n    border-radius: 8px;\n    font-size: 12.5px;\n    font-weight: 500;\n}\n\n.inventory-message.success {\n    background: #eef8f2;\n    border: 1px solid #cfe7d8;\n    color: #256847;\n}\n\n.inventory-message.error {\n    background: #fff1f2;\n    border: 1px solid #efced3;\n    color: #9f2f3a;\n}\n\n\n/* =========================================================\n   SUMMARY\n   ========================================================= */\n\n.inventory-summary {\n    display: grid;\n    grid-template-columns: repeat(4, minmax(0,1fr));\n    gap: 12px;\n    margin-bottom: 18px;\n}\n\n.summary-card {\n    position: relative;\n    display: flex;\n    align-items: center;\n    gap: 13px;\n\n    min-height: 82px;\n    padding: 14px 16px;\n\n    background: #ffffff;\n    border: 1px solid #e5e8ed;\n    border-radius: 12px;\n\n    box-shadow:\n        0 3px 12px rgba(31,41,61,.035);\n\n    overflow: hidden;\n}\n\n.summary-card::before {\n    content: \"\";\n    position: absolute;\n    left: 0;\n    top: 0;\n    bottom: 0;\n    width: 3px;\n    background: #7E1020;\n}\n\n.summary-card.available::before {\n    background: #2c805b;\n}\n\n.summary-card.low::before {\n    background: #d09a25;\n}\n\n.summary-card.out::before {\n    background: #b53a45;\n}\n\n.summary-icon {\n    width: 40px;\n    height: 40px;\n    flex: 0 0 40px;\n\n    display: flex;\n    align-items: center;\n    justify-content: center;\n\n    border-radius: 10px;\n\n    background: #faf0f2;\n    color: #7E1020;\n}\n\n.summary-card.available .summary-icon {\n    background: #eef8f3;\n    color: #287554;\n}\n\n.summary-card.low .summary-icon {\n    background: #fff7e7;\n    color: #aa7818;\n}\n\n.summary-card.out .summary-icon {\n    background: #fff1f2;\n    color: #aa3440;\n}\n\n.summary-icon svg {\n    width: 19px;\n    height: 19px;\n}\n\n.summary-info span {\n    display: block;\n    margin-bottom: 2px;\n\n    color: #818b9a;\n    font-size: 10px;\n    font-weight: 550;\n\n    letter-spacing: .25px;\n    text-transform: uppercase;\n}\n\n.summary-info strong {\n    display: block;\n\n    color: #283141;\n    font-size: 21px;\n    line-height: 1.2;\n    font-weight: 650;\n}\n\n.summary-info small {\n    display: block;\n    margin-top: 2px;\n\n    color: #9ba2ad;\n    font-size: 10.5px;\n    font-weight: 400;\n}\n\n\n/* =========================================================\n   MAIN CARD\n   ========================================================= */\n\n.inventory-card {\n    background: #ffffff;\n    border: 1px solid #e4e7ec;\n    border-radius: 14px;\n\n    box-shadow:\n        0 4px 18px rgba(31,41,61,.04);\n\n    overflow: hidden;\n}\n\n.inventory-card-header {\n    display: flex;\n    justify-content: space-between;\n    align-items: center;\n\n    gap: 18px;\n\n    padding: 18px 20px;\n\n    border-bottom:\n        1px solid #eceef2;\n}\n\n.inventory-card-header h2 {\n    margin: 0 0 4px;\n\n    color: #263043;\n\n    font-size: 17px;\n    font-weight: 650;\n}\n\n.inventory-card-header p {\n    margin: 0;\n\n    color: #8b94a1;\n\n    font-size: 12.5px;\n    font-weight: 400;\n}\n\n\n/* =========================================================\n   HEADER BUTTONS\n   ========================================================= */\n\n.header-actions {\n    display: flex;\n    align-items: center;\n    gap: 8px;\n    flex-wrap: wrap;\n}\n\n.admin-btn {\n    min-height: 37px;\n\n    display: inline-flex;\n    align-items: center;\n    justify-content: center;\n\n    gap: 6px;\n\n    padding: 8px 13px;\n\n    border-radius: 8px;\n\n    font-size: 11.5px;\n    font-weight: 550;\n\n    text-decoration: none;\n\n    cursor: pointer;\n\n    transition: .15s ease;\n}\n\n.admin-btn svg {\n    width: 14px;\n    height: 14px;\n}\n\n.admin-btn.primary {\n    background: #7E1020;\n    border: 1px solid #7E1020;\n    color: #ffffff;\n}\n\n.admin-btn.primary:hover {\n    background: #69101d;\n    border-color: #69101d;\n}\n\n.admin-btn.print {\n    background: #fffaf0;\n    border: 1px solid #e4cb8c;\n    color: #73571b;\n}\n\n.admin-btn.print:hover {\n    background: #fff5dc;\n}\n\n\n/* =========================================================\n   TOOLBAR\n   ========================================================= */\n\n.inventory-toolbar {\n    display: flex;\n    align-items: center;\n    justify-content: space-between;\n\n    gap: 12px;\n\n    padding: 13px 18px;\n\n    background: #fafbfc;\n\n    border-bottom:\n        1px solid #eceef2;\n}\n\n.toolbar-left {\n    flex: 1;\n\n    display: flex;\n    align-items: center;\n    gap: 8px;\n\n    flex-wrap: wrap;\n}\n\n.search-box {\n    position: relative;\n    width: 280px;\n}\n\n.search-box svg {\n    position: absolute;\n\n    top: 50%;\n    left: 11px;\n\n    width: 15px;\n    height: 15px;\n\n    transform:\n        translateY(-50%);\n\n    color: #9aa3af;\n}\n\n.search-box input {\n    width: 100%;\n    height: 36px;\n\n    padding:\n        0 11px 0 35px;\n\n    background: #ffffff;\n\n    border:\n        1px solid #dde1e6;\n\n    border-radius: 8px;\n\n    outline: none;\n\n    color: #465064;\n\n    font-size: 11.5px;\n    font-weight: 400;\n}\n\n.filter-select {\n    height: 36px;\n    min-width: 140px;\n\n    padding:\n        0 28px 0 10px;\n\n    background: #ffffff;\n\n    border:\n        1px solid #dde1e6;\n\n    border-radius: 8px;\n\n    outline: none;\n\n    color: #596476;\n\n    font-size: 11.5px;\n    font-weight: 400;\n}\n\n.search-box input:focus,\n.filter-select:focus {\n    border-color: #a85c67;\n\n    box-shadow:\n        0 0 0 3px\n        rgba(126,16,32,.05);\n}\n\n.reset-btn {\n    height: 36px;\n\n    padding:\n        0 11px;\n\n    background: #ffffff;\n\n    border:\n        1px solid #dde1e6;\n\n    border-radius: 8px;\n\n    color: #687284;\n\n    font-size: 11.5px;\n    font-weight: 500;\n\n    cursor: pointer;\n}\n\n.reset-btn:hover {\n    border-color: #c9a5aa;\n    color: #7E1020;\n}\n\n.result-count {\n    flex-shrink: 0;\n\n    color: #8c95a2;\n\n    font-size: 11.5px;\n    font-weight: 400;\n}\n\n.result-count strong {\n    color: #7E1020;\n    font-weight: 600;\n}\n\n\n/* =========================================================\n   TABLE\n   ========================================================= */\n\n.inventory-table-wrap {\n    width: 100%;\n    overflow-x: auto;\n}\n\n.inventory-table {\n    width: 100%;\n    min-width: 980px;\n\n    border-collapse: collapse;\n}\n\n.inventory-table th {\n    padding: 11px 13px;\n\n    background: #f8f9fb;\n\n    border-bottom:\n        1px solid #e7eaf0;\n\n    color: #737e8e;\n\n    font-size: 10px;\n    font-weight: 600;\n\n    letter-spacing: .3px;\n\n    text-align: left;\n    text-transform: uppercase;\n\n    white-space: nowrap;\n}\n\n.inventory-table td {\n    padding: 12px 13px;\n\n    border-bottom:\n        1px solid #edf0f3;\n\n    color: #566173;\n\n    font-size: 12px;\n    font-weight: 400;\n\n    line-height: 1.45;\n\n    vertical-align: middle;\n}\n\n.inventory-table tbody tr:hover {\n    background: #fdfbfb;\n}\n\n.inventory-table tbody tr:last-child td {\n    border-bottom: none;\n}\n\n\n/* =========================================================\n   CODE\n   ========================================================= */\n\n.item-code {\n    display: inline-flex;\n    align-items: center;\n\n    gap: 6px;\n\n    color: #374153;\n\n    font-size: 11px;\n    font-weight: 600;\n\n    white-space: nowrap;\n}\n\n.item-code::before {\n    content: \"\";\n\n    width: 5px;\n    height: 5px;\n\n    border-radius: 50%;\n\n    background: #D4A63A;\n}\n\n\n/* =========================================================\n   ITEM INFO\n   ========================================================= */\n\n.item-info {\n    min-width: 205px;\n    max-width: 310px;\n}\n\n.item-info .item-name {\n    display: block;\n\n    margin-bottom: 3px;\n\n    color: #263043;\n\n    font-size: 13px;\n    font-weight: 600;\n\n    line-height: 1.35;\n}\n\n.item-meta {\n    display: flex;\n    flex-wrap: wrap;\n\n    gap: 3px 7px;\n\n    color: #929aa7;\n\n    font-size: 10.5px;\n    font-weight: 400;\n\n    line-height: 1.4;\n}\n\n.item-meta span:not(:last-child)::after {\n    content: \"•\";\n\n    margin-left: 7px;\n\n    color: #c0c5cd;\n}\n\n\n/* =========================================================\n   STOCK\n   ========================================================= */\n\n.stock-info strong {\n    color: #7E1020;\n\n    font-size: 14px;\n    font-weight: 650;\n}\n\n.stock-info .stock-unit {\n    margin-left: 2px;\n\n    color: #5e697a;\n\n    font-size: 10.5px;\n    font-weight: 500;\n}\n\n.stock-info small {\n    display: block;\n\n    margin-top: 1px;\n\n    color: #9aa2ad;\n\n    font-size: 9.5px;\n    font-weight: 400;\n}\n\n\n/* =========================================================\n   STATUS\n   ========================================================= */\n\n.inventory-status {\n    display: inline-flex;\n    align-items: center;\n\n    gap: 5px;\n\n    padding: 5px 8px;\n\n    border-radius: 20px;\n\n    font-size: 10px;\n    font-weight: 550;\n\n    white-space: nowrap;\n}\n\n.inventory-status::before {\n    content: \"\";\n\n    width: 5px;\n    height: 5px;\n\n    border-radius: 50%;\n}\n\n.inventory-status.AVAILABLE {\n    background: #edf8f2;\n    border: 1px solid #d1e9dc;\n    color: #2c6f50;\n}\n\n.inventory-status.AVAILABLE::before {\n    background: #2f825d;\n}\n\n.inventory-status.LOW_STOCK {\n    background: #fff7e8;\n    border: 1px solid #eddeb8;\n    color: #89641c;\n}\n\n.inventory-status.LOW_STOCK::before {\n    background: #c08a1b;\n}\n\n.inventory-status.OUT_OF_STOCK {\n    background: #fff1f2;\n    border: 1px solid #efcfd3;\n    color: #9f3440;\n}\n\n.inventory-status.OUT_OF_STOCK::before {\n    background: #b53a45;\n}\n\n\n/* =========================================================\n   ACTION\n   ========================================================= */\n\n.action-group {\n    display: flex;\n    align-items: center;\n\n    gap: 5px;\n\n    white-space: nowrap;\n}\n\n.table-btn {\n    min-height: 30px;\n\n    display: inline-flex;\n    align-items: center;\n    justify-content: center;\n\n    padding: 5px 8px;\n\n    border-radius: 7px;\n\n    font-size: 10.5px;\n    font-weight: 500;\n\n    cursor: pointer;\n\n    transition: .15s ease;\n}\n\n.table-btn.stock {\n    background: #eef8f3;\n    border: 1px solid #cfe7da;\n    color: #287554;\n}\n\n.table-btn.stock:hover {\n    background: #e2f3e9;\n    border-color: #b9ddc9;\n}\n\n.table-btn.view {\n    background: #ffffff;\n    border: 1px solid #d9dde4;\n    color: #596476;\n}\n\n.table-btn.view:hover {\n    background: #f6f7f9;\n}\n\n.table-btn.edit {\n    background: #fffafb;\n    border: 1px solid #ead5d8;\n    color: #7E1020;\n}\n\n.table-btn.edit:hover {\n    background: #faeef0;\n}\n\n.table-btn.delete {\n    background: #fff3f4;\n    border: 1px solid #efced2;\n    color: #a02f3a;\n}\n\n.table-btn.delete:hover {\n    background: #fde7e9;\n}\n\n\n/* =========================================================\n   EMPTY\n   ========================================================= */\n\n.empty-row td {\n    padding: 45px 20px !important;\n    text-align: center;\n}\n\n.empty-row strong {\n    display: block;\n\n    color: #465064;\n\n    font-size: 13px;\n    font-weight: 600;\n}\n\n.empty-row span {\n    display: block;\n\n    margin-top: 4px;\n\n    color: #969eab;\n\n    font-size: 11px;\n}\n\n.no-result {\n    display: none;\n\n    padding: 35px 20px;\n\n    border-top:\n        1px solid #eef0f3;\n\n    text-align: center;\n\n    color: #8992a2;\n\n    font-size: 11.5px;\n}\n\n\n/* =========================================================\n   MODAL\n   ========================================================= */\n\n.inventory-modal {\n    position: fixed;\n    inset: 0;\n\n    z-index: 99999;\n\n    display: none;\n    align-items: center;\n    justify-content: center;\n\n    padding: 20px;\n\n    overflow-y: auto;\n    overscroll-behavior: contain;\n\n    background:\n        rgba(20,25,34,.52);\n\n    backdrop-filter:\n        blur(2px);\n}\n\n.inventory-modal.show {\n    display: flex;\n}/* =========================================================\n   MODAL CARD\n   ========================================================= */\n\n.modal-card {\n    width: min(720px, 100%);\n    max-height: calc(100vh - 40px);\n\n    display: flex;\n    flex-direction: column;\n\n    background: #ffffff;\n\n    border: 1px solid #e2e5ea;\n    border-radius: 14px;\n\n    box-shadow:\n        0 20px 60px rgba(20,25,34,.18);\n\n    overflow: hidden;\n}\n\n.modal-card.large {\n    width: min(860px, 100%);\n}\n\n/* Pastikan form dalam modal mempunyai ruang scroll sendiri */\n.modal-card > form {\n    flex: 1 1 auto;\n    min-height: 0;\n    display: flex;\n    flex-direction: column;\n    overflow: hidden;\n}\n\n\n/* =========================================================\n   MODAL HEADER\n   ========================================================= */\n\n.modal-header {\n    flex: 0 0 auto;\n\n    display: flex;\n    align-items: center;\n    justify-content: space-between;\n\n    gap: 14px;\n\n    padding: 16px 18px;\n\n    border-bottom:\n        1px solid #eceef2;\n\n    background:\n        linear-gradient(\n            180deg,\n            #ffffff,\n            #fcfcfd\n        );\n}\n\n.modal-header h3 {\n    margin: 0 0 3px;\n\n    color: #263043;\n\n    font-size: 16px;\n    font-weight: 650;\n}\n\n.modal-header p {\n    margin: 0;\n\n    color: #9098a5;\n\n    font-size: 11.5px;\n    font-weight: 400;\n}\n\n.modal-close {\n    width: 32px;\n    height: 32px;\n\n    flex: 0 0 32px;\n\n    display: inline-flex;\n    align-items: center;\n    justify-content: center;\n\n    padding: 0;\n\n    background: #ffffff;\n\n    border:\n        1px solid #dfe3e8;\n\n    border-radius: 8px;\n\n    color: #747e8d;\n\n    font-size: 17px;\n    font-weight: 400;\n\n    cursor: pointer;\n\n    transition: .15s ease;\n}\n\n.modal-close:hover {\n    background: #fff4f5;\n\n    border-color: #e1c3c8;\n\n    color: #7E1020;\n}\n\n\n/* =========================================================\n   MODAL BODY\n   ========================================================= */\n\n.modal-body {\n    flex: 1;\n\n    min-height: 0;\n\n    padding: 18px;\n\n    overflow-y: auto;\n    overscroll-behavior: contain;\n    scrollbar-gutter: stable;\n}\n\n\n/* =========================================================\n   FORM\n   ========================================================= */\n\n.form-grid {\n    display: grid;\n\n    grid-template-columns:\n        repeat(\n            2,\n            minmax(0, 1fr)\n        );\n\n    gap: 13px 14px;\n}\n\n.form-group {\n    min-width: 0;\n}\n\n.form-group.full {\n    grid-column:\n        1 / -1;\n}\n\n.new-option-field {\n    width: 100%;\n    min-width: 0;\n}\n\n.new-option-field label {\n    display: block;\n    margin: 0 0 5px;\n    color: #535e70;\n    font-size: 11px;\n    font-weight: 550;\n}\n\n.new-option-field .form-control {\n    width: 100%;\n}\n\n.form-group label {\n    display: block;\n\n    margin-bottom: 5px;\n\n    color: #535e70;\n\n    font-size: 11px;\n    font-weight: 550;\n}\n\n.form-group label .optional {\n    color: #9ba2ae;\n\n    font-size: 9.5px;\n    font-weight: 400;\n}\n\n.form-control {\n    width: 100%;\n    min-width: 0;\n\n    height: 37px;\n\n    padding:\n        0 10px;\n\n    background: #ffffff;\n\n    border:\n        1px solid #dce0e6;\n\n    border-radius: 8px;\n\n    color: #414b5d;\n\n    font-size: 11.5px;\n    font-weight: 400;\n\n    outline: none;\n\n    transition: .15s ease;\n}\n\ntextarea.form-control {\n    min-height: 82px;\n    height: auto;\n\n    padding:\n        9px 10px;\n\n    line-height: 1.45;\n\n    resize: vertical;\n}\n\n.form-control:focus {\n    border-color: #a75d67;\n\n    box-shadow:\n        0 0 0 3px\n        rgba(126,16,32,.05);\n}\n\n.form-control::placeholder {\n    color: #a4abb5;\n}\n\n.form-help {\n    display: block;\n\n    margin-top: 4px;\n\n    color: #969eaa;\n\n    font-size: 9.5px;\n    line-height: 1.4;\n}\n\n\n/* =========================================================\n   MODAL FOOTER\n   ========================================================= */\n\n.modal-footer {\n    flex: 0 0 auto;\n\n    display: flex;\n    align-items: center;\n    justify-content: flex-end;\n\n    gap: 8px;\n\n    padding: 13px 18px;\n\n    background: #fafbfc;\n\n    border-top:\n        1px solid #eceef2;\n}\n\n.modal-btn {\n    min-height: 36px;\n\n    display: inline-flex;\n    align-items: center;\n    justify-content: center;\n\n    padding:\n        7px 13px;\n\n    border-radius: 8px;\n\n    font-size: 11px;\n    font-weight: 550;\n\n    cursor: pointer;\n\n    transition: .15s ease;\n}\n\n.modal-btn.cancel {\n    background: #ffffff;\n\n    border:\n        1px solid #d9dde4;\n\n    color: #667183;\n}\n\n.modal-btn.cancel:hover {\n    background: #f5f6f8;\n}\n\n.modal-btn.save {\n    background: #7E1020;\n\n    border:\n        1px solid #7E1020;\n\n    color: #ffffff;\n}\n\n.modal-btn.save:hover {\n    background: #69101d;\n}\n\n\n/* =========================================================\n   VIEW DETAILS\n   ========================================================= */\n\n.detail-grid {\n    display: grid;\n\n    grid-template-columns:\n        repeat(\n            2,\n            minmax(0, 1fr)\n        );\n\n    gap: 12px;\n}\n\n.detail-item {\n    padding: 11px 12px;\n\n    background: #fafbfc;\n\n    border:\n        1px solid #eceef2;\n\n    border-radius: 9px;\n\n    min-width: 0;\n}\n\n.detail-item.full {\n    grid-column:\n        1 / -1;\n}\n\n.detail-item span {\n    display: block;\n\n    margin-bottom: 4px;\n\n    color: #929aa7;\n\n    font-size: 9.5px;\n    font-weight: 550;\n\n    text-transform: uppercase;\n\n    letter-spacing: .25px;\n}\n\n.detail-item strong {\n    display: block;\n\n    color: #3c4658;\n\n    font-size: 12px;\n    font-weight: 550;\n\n    line-height: 1.45;\n\n    overflow-wrap: anywhere;\n}\n\n\n/* =========================================================\n   DELETE MODAL\n   ========================================================= */\n\n.delete-warning {\n    display: flex;\n\n    align-items: flex-start;\n\n    gap: 12px;\n\n    padding: 13px;\n\n    background: #fff5f5;\n\n    border:\n        1px solid #efd6d9;\n\n    border-radius: 9px;\n}\n\n.delete-warning-icon {\n    width: 36px;\n    height: 36px;\n\n    flex: 0 0 36px;\n\n    display: flex;\n    align-items: center;\n    justify-content: center;\n\n    background: #ffe8ea;\n\n    border-radius: 9px;\n\n    color: #a8323e;\n}\n\n.delete-warning-icon svg {\n    width: 17px;\n    height: 17px;\n}\n\n.delete-warning strong {\n    display: block;\n\n    margin-bottom: 3px;\n\n    color: #7e2932;\n\n    font-size: 12px;\n    font-weight: 600;\n}\n\n.delete-warning p {\n    margin: 0;\n\n    color: #875a60;\n\n    font-size: 10.5px;\n    line-height: 1.45;\n}\n\n\n/* =========================================================\n   TOP RIGHT HEADER\n   NOTIFICATION + USER\n   ========================================================= */\n\n.inventory-header-right {\n    display: flex;\n\n    align-items: center;\n\n    justify-content: flex-end;\n\n    gap: 10px;\n\n    flex-shrink: 0;\n}\n\n\n/* =========================================================\n   NOTIFICATION BUTTON\n   ========================================================= */\n\n.inventory-notification-btn {\n    position: relative;\n\n    width: 42px;\n    height: 42px;\n\n    flex:\n        0 0 42px;\n\n    display: inline-flex;\n\n    align-items: center;\n\n    justify-content: center;\n\n    background: #ffffff;\n\n    border:\n        1px solid #e3e7ed;\n\n    border-radius: 12px;\n\n    color: #718096;\n\n    text-decoration: none;\n\n    box-shadow:\n        0 3px 12px\n        rgba(31,41,61,.035);\n\n    transition: .15s ease;\n}\n\n.inventory-notification-btn:hover {\n    background: #fffafb;\n\n    border-color: #dbc4c8;\n\n    color: #7E1020;\n}\n\n.inventory-notification-btn svg {\n    width: 19px;\n    height: 19px;\n\n    fill: none;\n\n    stroke: currentColor;\n\n    stroke-width: 1.8;\n\n    stroke-linecap: round;\n\n    stroke-linejoin: round;\n}\n\n\n/* =========================================================\n   NOTIFICATION BADGE\n   ========================================================= */\n\n.inventory-notification-badge {\n    position: absolute;\n\n    top: -5px;\n    right: -5px;\n\n    min-width: 18px;\n    height: 18px;\n\n    display: flex;\n\n    align-items: center;\n\n    justify-content: center;\n\n    padding:\n        0 5px;\n\n    background: #7E1020;\n\n    border:\n        2px solid #f6f7fa;\n\n    border-radius: 20px;\n\n    color: #ffffff;\n\n    font-size: 9px;\n    line-height: 1;\n    font-weight: 600;\n}\n\n\n/* =========================================================\n   USER CARD\n   ========================================================= */\n\n.inventory-user-card {\n    min-height: 42px;\n\n    display: flex;\n\n    align-items: center;\n\n    gap: 9px;\n\n    padding:\n        5px 11px 5px 6px;\n\n    background: #ffffff;\n\n    border:\n        1px solid #e3e7ed;\n\n    border-radius: 12px;\n\n    box-shadow:\n        0 3px 12px\n        rgba(31,41,61,.035);\n}\n\n.inventory-user-avatar {\n    width: 32px;\n    height: 32px;\n\n    flex:\n        0 0 32px;\n\n    display: flex;\n\n    align-items: center;\n\n    justify-content: center;\n\n    background: #fff6ec;\n\n    border:\n        1px solid #f0ded3;\n\n    border-radius: 9px;\n\n    color: #7E1020;\n\n    font-size: 12px;\n\n    font-weight: 650;\n}\n\n.inventory-user-info {\n    display: flex;\n\n    flex-direction: column;\n\n    min-width: 0;\n}\n\n.inventory-user-name {\n    max-width: 150px;\n\n    overflow: hidden;\n\n    text-overflow: ellipsis;\n\n    white-space: nowrap;\n\n    color: #263043;\n\n    font-size: 12px;\n\n    line-height: 1.3;\n\n    font-weight: 600;\n}\n\n.inventory-user-role {\n    margin-top: 1px;\n\n    color: #9199a6;\n\n    font-size: 9.5px;\n\n    line-height: 1.25;\n\n    font-weight: 400;\n}\n\n\n/* =========================================================\n   RESPONSIVE\n   ========================================================= */\n\n@media (max-width: 1100px) {\n\n    .inventory-summary {\n        grid-template-columns:\n            repeat(\n                2,\n                minmax(0,1fr)\n            );\n    }\n\n    .inventory-card-header {\n        align-items: flex-start;\n\n        flex-direction: column;\n    }\n\n    .header-actions {\n        width: 100%;\n    }\n\n    .inventory-toolbar {\n        align-items: flex-start;\n\n        flex-direction: column;\n    }\n\n    .toolbar-left {\n        width: 100%;\n    }\n\n    .result-count {\n        width: 100%;\n    }\n}\n\n\n@media (max-width: 760px) {\n\n    .inventory-page-header {\n        flex-direction: row;\n\n        align-items: flex-start;\n    }\n\n    .inventory-header-right {\n        gap: 6px;\n    }\n\n    .inventory-user-card {\n        min-height: 40px;\n\n        padding-right: 7px;\n    }\n\n    .inventory-user-info {\n        display: none;\n    }\n\n    .inventory-notification-btn {\n        width: 40px;\n        height: 40px;\n\n        flex-basis: 40px;\n    }\n\n    .inventory-user-avatar {\n        width: 30px;\n        height: 30px;\n\n        flex-basis: 30px;\n    }\n\n    .inventory-summary {\n        grid-template-columns:\n            1fr;\n    }\n\n    .toolbar-left {\n        flex-direction: column;\n\n        align-items: stretch;\n    }\n\n    .search-box,\n    .filter-select,\n    .reset-btn {\n        width: 100%;\n    }\n\n    .form-grid,\n    .detail-grid {\n        grid-template-columns:\n            1fr;\n    }\n\n    .form-group.full,\n    .detail-item.full {\n        grid-column:\n            auto;\n    }\n\n    .modal-footer {\n        flex-direction: column-reverse;\n    }\n\n    .modal-btn {\n        width: 100%;\n    }\n}\n\n\n@media (max-width: 520px) {\n\n    .inventory-page-header h1 {\n        font-size: 21px;\n    }\n\n    .inventory-page-header p {\n        font-size: 11.5px;\n    }\n\n    .inventory-header-right {\n        flex-shrink: 0;\n    }\n\n    .inventory-card-header {\n        padding:\n            15px;\n    }\n\n    .inventory-toolbar {\n        padding:\n            12px 15px;\n    }\n\n    .header-actions {\n        flex-direction: column;\n\n        align-items: stretch;\n    }\n\n    .admin-btn {\n        width: 100%;\n    }\n\n    .summary-card {\n        min-height: 76px;\n\n        padding:\n            12px 14px;\n    }\n\n    .modal-card {\n        max-height: 95vh;\n    }\n\n    .modal-header,\n    .modal-body,\n    .modal-footer {\n        padding-left: 14px;\n\n        padding-right: 14px;\n    }\n}\n\n/* Compact mobile layout aligned with other LeaveHub pages. */\n@media (max-width: 650px) {\n    main { width:100% !important; max-width:100vw !important; min-width:0 !important; margin-left:0 !important; padding:74px 13px 28px !important; overflow-x:hidden !important; }\n    .inventory-page { width:100% !important; max-width:100% !important; min-width:0 !important; margin:0 !important; overflow-x:hidden !important; }\n    .inventory-page-header { position:relative !important; display:block !important; min-height:42px !important; margin:0 0 14px !important; }\n    .inventory-page-header > div:first-child { width:100% !important; min-width:0 !important; padding-right:100px !important; }\n    .inventory-page-header h1 { margin:0 0 5px !important; font-size:23px !important; line-height:1.2 !important; }\n    .inventory-page-header p { margin:0 !important; font-size:12px !important; line-height:1.4 !important; }\n    .inventory-header-right { position:absolute !important; top:0 !important; right:0 !important; z-index:10 !important; display:flex !important; align-items:center !important; justify-content:flex-end !important; gap:6px !important; margin:0 !important; }\n    .inventory-notification-btn,.inventory-user-card { width:42px !important; min-width:42px !important; height:42px !important; min-height:42px !important; flex:0 0 42px !important; justify-content:center !important; padding:5px !important; }\n    .inventory-user-info { display:none !important; }\n    .inventory-user-avatar { width:30px !important; height:30px !important; flex:0 0 30px !important; }\n    .inventory-summary { grid-template-columns:repeat(2,minmax(0,1fr)) !important; gap:9px !important; margin:0 0 14px !important; }\n    .summary-card { min-width:0 !important; min-height:76px !important; gap:8px !important; padding:10px !important; border-radius:14px !important; }\n    .summary-icon { width:34px !important; height:34px !important; flex:0 0 34px !important; }\n    .summary-info { min-width:0 !important; }\n    .summary-info span { font-size:9px !important; line-height:1.25 !important; }\n    .summary-info strong { font-size:20px !important; }\n    .summary-info small { font-size:9px !important; line-height:1.25 !important; }\n    .inventory-card,.inventory-card-header { width:100% !important; min-width:0 !important; }\n    .inventory-card { border-radius:14px !important; }\n    .inventory-card-header { padding:14px !important; }\n    .inventory-card-header h2 { font-size:16px !important; }\n    .inventory-toolbar { align-items:stretch !important; gap:8px !important; padding:12px !important; }\n    .toolbar-left { display:grid !important; grid-template-columns:minmax(0,1fr) minmax(0,1fr) !important; gap:7px !important; width:100% !important; }\n    .search-box { grid-column:1/-1 !important; width:100% !important; }\n    .filter-select,.reset-btn { width:100% !important; min-width:0 !important; }\n    .inventory-table-wrap { width:100% !important; max-width:100% !important; padding:8px !important; overflow-x:hidden !important; background:#f5f7fa !important; }\n    .inventory-table { display:block !important; width:100% !important; min-width:0 !important; }\n    .inventory-table thead { display:none !important; }\n    .inventory-table tbody { display:grid !important; grid-template-columns:minmax(0,1fr) !important; gap:8px !important; width:100% !important; }\n    .inventory-table tbody .inventory-data-row { display:grid !important; grid-template-columns:minmax(0,1fr) auto !important; align-items:center !important; gap:6px 9px !important; width:100% !important; min-width:0 !important; padding:10px !important; border:1px solid #dce2ea !important; border-left:4px solid #a11f31 !important; border-radius:12px !important; background:#fff !important; box-shadow:0 2px 7px rgba(23,32,51,.06) !important; }\n    .inventory-table tbody .inventory-data-row td { display:block !important; width:auto !important; min-width:0 !important; padding:0 !important; border:0 !important; font-size:10px !important; line-height:1.3 !important; overflow-wrap:anywhere !important; }\n    .inventory-table tbody .inventory-data-row td:nth-child(1) { grid-column:1 !important; grid-row:1 !important; color:#8993a5 !important; font-size:9px !important; }\n    .inventory-table tbody .inventory-data-row td:nth-child(2) { grid-column:1 !important; grid-row:2 !important; }\n    .inventory-table tbody .inventory-data-row td:nth-child(3) { grid-column:1 !important; grid-row:3 !important; color:#788497 !important; font-size:9px !important; }\n    .inventory-table tbody .inventory-data-row td:nth-child(4) { grid-column:2 !important; grid-row:2 !important; justify-self:end !important; }\n    .inventory-table tbody .inventory-data-row td:nth-child(5) { grid-column:1 !important; grid-row:4 !important; }\n    .inventory-table tbody .inventory-data-row td:nth-child(6) { grid-column:2 !important; grid-row:1 !important; grid-row:1 / 2 !important; justify-self:end !important; }\n    .inventory-table tbody .inventory-data-row td:nth-child(7) { grid-column:1/-1 !important; grid-row:5 !important; padding-top:7px !important; border-top:1px solid #edf0f4 !important; }\n    .item-code { font-size:9px !important; }\n    .item-name { font-size:11px !important; font-weight:700 !important; line-height:1.25 !important; }\n    .item-meta { display:flex !important; flex-wrap:wrap !important; gap:2px 5px !important; font-size:9px !important; }\n    .stock-info { text-align:right !important; }\n    .stock-info strong { font-size:14px !important; }\n    .stock-info small { display:block !important; font-size:8px !important; }\n    .inventory-status { max-width:92px !important; white-space:normal !important; text-align:center !important; font-size:8px !important; line-height:1.2 !important; }\n    .action-group { display:flex !important; flex-wrap:nowrap !important; gap:5px !important; }\n    .action-group .table-btn { flex:1 1 0 !important; min-width:0 !important; min-height:30px !important; padding:5px 6px !important; font-size:9px !important; }\n}\n"; } %>
<%! private static String inventoryJs() { return "\n\ndocument.addEventListener(\n    \"DOMContentLoaded\",\n    function () {\n\n        // =====================================================\n        // ELEMENTS\n        // =====================================================\n\n        const searchInput =\n            document.getElementById(\n                \"inventorySearch\"\n            );\n\n        const categoryFilter =\n            document.getElementById(\n                \"categoryFilter\"\n            );\n\n        const statusFilter =\n            document.getElementById(\n                \"statusFilter\"\n            );\n\n        const resetButton =\n            document.getElementById(\n                \"resetInventoryFilter\"\n            );\n\n        const visibleCount =\n            document.getElementById(\n                \"inventoryVisibleCount\"\n            );\n\n        const noResult =\n            document.getElementById(\n                \"inventoryNoResult\"\n            );\n\n\n        // =====================================================\n        // FILTER INVENTORY\n        // =====================================================\n\n        function filterInventory() {\n\n            const keyword =\n                searchInput\n                    ? searchInput.value\n                        .trim()\n                        .toLowerCase()\n                    : \"\";\n\n            const selectedCategory =\n                categoryFilter\n                    ? categoryFilter.value\n                        .trim()\n                        .toLowerCase()\n                    : \"\";\n\n            const selectedStatus =\n                statusFilter\n                    ? statusFilter.value\n                        .trim()\n                        .toUpperCase()\n                    : \"\";\n\n\n            const rows =\n                document.querySelectorAll(\n                    \".inventory-data-row\"\n                );\n\n\n            let count = 0;\n\n\n            rows.forEach(\n                function (row) {\n\n                    const searchData =\n                        (\n                            row.dataset.search || \"\"\n                        ).toLowerCase();\n\n                    const rowCategory =\n                        (\n                            row.dataset.category || \"\"\n                        )\n                        .trim()\n                        .toLowerCase();\n\n                    const rowStatus =\n                        (\n                            row.dataset.status || \"\"\n                        )\n                        .trim()\n                        .toUpperCase();\n\n\n                    const keywordMatch =\n                        keyword === \"\"\n                        ||\n                        searchData.includes(\n                            keyword\n                        );\n\n\n                    const categoryMatch =\n                        selectedCategory === \"\"\n                        ||\n                        rowCategory ===\n                            selectedCategory;\n\n\n                    const statusMatch =\n                        selectedStatus === \"\"\n                        ||\n                        rowStatus ===\n                            selectedStatus;\n\n\n                    if (\n                        keywordMatch\n                        &&\n                        categoryMatch\n                        &&\n                        statusMatch\n                    ) {\n\n                        row.style.display = \"\";\n\n                        count++;\n\n                    }\n                    else {\n\n                        row.style.display =\n                            \"none\";\n                    }\n\n                }\n            );\n\n\n            // =================================================\n            // UPDATE COUNT\n            // =================================================\n\n            if (visibleCount) {\n\n                visibleCount.textContent =\n                    count;\n            }\n\n\n            // =================================================\n            // NO RESULT\n            // =================================================\n\n            if (noResult) {\n\n                if (\n                    rows.length > 0\n                    &&\n                    count === 0\n                ) {\n\n                    noResult.style.display =\n                        \"block\";\n\n                }\n                else {\n\n                    noResult.style.display =\n                        \"none\";\n                }\n            }\n        }\n\n\n        // =====================================================\n        // SEARCH EVENT\n        // =====================================================\n\n        if (searchInput) {\n\n            searchInput.addEventListener(\n                \"input\",\n                filterInventory\n            );\n        }\n\n\n        // =====================================================\n        // CATEGORY EVENT\n        // =====================================================\n\n        if (categoryFilter) {\n\n            categoryFilter.addEventListener(\n                \"change\",\n                filterInventory\n            );\n        }\n\n\n        // =====================================================\n        // STATUS EVENT\n        // =====================================================\n\n        if (statusFilter) {\n\n            statusFilter.addEventListener(\n                \"change\",\n                filterInventory\n            );\n        }\n\n\n        // =====================================================\n        // RESET FILTER\n        // =====================================================\n\n        if (resetButton) {\n\n            resetButton.addEventListener(\n                \"click\",\n                function () {\n\n                    if (searchInput) {\n                        searchInput.value = \"\";\n                    }\n\n                    if (categoryFilter) {\n                        categoryFilter.value = \"\";\n                    }\n\n                    if (statusFilter) {\n                        statusFilter.value = \"\";\n                    }\n\n                    filterInventory();\n\n                    if (searchInput) {\n                        searchInput.focus();\n                    }\n                }\n            );\n        }\n\n\n        // =====================================================\n        // ADD QUANTITY VALIDATION\n        // =====================================================\n\n        const addQuantity =\n            document.getElementById(\n                \"addQuantity\"\n            );\n\n        const addAvailable =\n            document.getElementById(\n                \"addAvailableQuantity\"\n            );\n\n\n        function validateAddQuantity() {\n\n            if (\n                !addQuantity\n                ||\n                !addAvailable\n            ) {\n                return;\n            }\n\n\n            let total =\n                parseInt(\n                    addQuantity.value || \"0\",\n                    10\n                );\n\n            let available =\n                parseInt(\n                    addAvailable.value || \"0\",\n                    10\n                );\n\n\n            if (\n                Number.isNaN(total)\n                ||\n                total < 0\n            ) {\n                total = 0;\n            }\n\n\n            if (\n                Number.isNaN(available)\n                ||\n                available < 0\n            ) {\n                available = 0;\n            }\n\n\n            if (available > total) {\n\n                addAvailable.setCustomValidity(\n                    \"Kuantiti tersedia tidak boleh melebihi jumlah kuantiti.\"\n                );\n\n            }\n            else {\n\n                addAvailable.setCustomValidity(\n                    \"\"\n                );\n            }\n        }\n\n\n        if (addQuantity) {\n\n            addQuantity.addEventListener(\n                \"input\",\n                validateAddQuantity\n            );\n        }\n\n\n        if (addAvailable) {\n\n            addAvailable.addEventListener(\n                \"input\",\n                validateAddQuantity\n            );\n        }\n\n\n        // =====================================================\n        // EDIT QUANTITY VALIDATION\n        // =====================================================\n\n        const editQuantity =\n            document.getElementById(\n                \"editQuantity\"\n            );\n\n        const editAvailable =\n            document.getElementById(\n                \"editAvailableQuantity\"\n            );\n\n\n        function validateEditQuantity() {\n\n            if (\n                !editQuantity\n                ||\n                !editAvailable\n            ) {\n                return;\n            }\n\n\n            let total =\n                parseInt(\n                    editQuantity.value || \"0\",\n                    10\n                );\n\n            let available =\n                parseInt(\n                    editAvailable.value || \"0\",\n                    10\n                );\n\n\n            if (\n                Number.isNaN(total)\n                ||\n                total < 0\n            ) {\n                total = 0;\n            }\n\n\n            if (\n                Number.isNaN(available)\n                ||\n                available < 0\n            ) {\n                available = 0;\n            }\n\n\n            if (available > total) {\n\n                editAvailable.setCustomValidity(\n                    \"Kuantiti tersedia tidak boleh melebihi jumlah kuantiti.\"\n                );\n\n            }\n            else {\n\n                editAvailable.setCustomValidity(\n                    \"\"\n                );\n            }\n        }\n\n\n        if (editQuantity) {\n\n            editQuantity.addEventListener(\n                \"input\",\n                validateEditQuantity\n            );\n        }\n\n\n        if (editAvailable) {\n\n            editAvailable.addEventListener(\n                \"input\",\n                validateEditQuantity\n            );\n        }\n\n\n        // =====================================================\n        // CLICK OUTSIDE MODAL\n        // =====================================================\n\n        document\n            .querySelectorAll(\n                \".inventory-modal\"\n            )\n            .forEach(\n                function (modal) {\n\n                    modal.addEventListener(\n                        \"click\",\n                        function (event) {\n\n                            if (\n                                event.target ===\n                                modal\n                            ) {\n\n                                closeModal(\n                                    modal.id\n                                );\n                            }\n                        }\n                    );\n                }\n            );\n\n\n        // =====================================================\n        // ESC CLOSE\n        // =====================================================\n\n        document.addEventListener(\n            \"keydown\",\n            function (event) {\n\n                if (\n                    event.key === \"Escape\"\n                ) {\n\n                    document\n                        .querySelectorAll(\n                            \".inventory-modal.show\"\n                        )\n                        .forEach(\n                            function (modal) {\n\n                                closeModal(\n                                    modal.id\n                                );\n                            }\n                        );\n                }\n            }\n        );\n\n\n        // =====================================================\n        // INITIAL FILTER\n        // =====================================================\n\n        filterInventory();\n\n    }\n);\n\n\n// =========================================================\n// ADD INVENTORY - NEW CATEGORY TOGGLE\n// =========================================================\n\nfunction updateNewCategoryField() {\n\n    const category = document.getElementById(\"addCategory\");\n    const group = document.getElementById(\"newCategoryGroup\");\n    const input = document.getElementById(\"newCategoryName\");\n\n    if (!category || !group || !input) {\n        return;\n    }\n\n    const isNew = category.value === \"__NEW__\";\n\n    group.style.display = isNew ? \"flex\" : \"none\";\n    input.required = isNew;\n\n    if (!isNew) {\n        input.value = \"\";\n        input.setCustomValidity(\"\");\n    }\n}\n\ndocument.addEventListener(\"DOMContentLoaded\", function () {\n\n    const category = document.getElementById(\"addCategory\");\n\n    if (category) {\n        category.addEventListener(\"change\", updateNewCategoryField);\n        updateNewCategoryField();\n    }\n});\n\n\n// =========================================================\n// OPEN ADD MODAL\n// =========================================================\n\nfunction openAddModal() {\n\n    const modal =\n        document.getElementById(\n            \"addInventoryModal\"\n        );\n\n\n    if (!modal) {\n        return;\n    }\n\n\n    // =====================================================\n    // RESET FORM\n    // =====================================================\n\n    const form =\n        modal.querySelector(\n            \"form\"\n        );\n\n\n    if (form) {\n\n        form.reset();\n    }\n\n    updateNewCategoryField();\n\n\n    // =====================================================\n    // DEFAULT VALUES\n    // =====================================================\n\n    const quantity =\n        document.getElementById(\n            \"addQuantity\"\n        );\n\n    const available =\n        document.getElementById(\n            \"addAvailableQuantity\"\n        );\n\n    const condition =\n        document.getElementById(\n            \"addCondition\"\n        );\n\n    const unit =\n        document.getElementById(\n            \"addUnit\"\n        );\n\n\n    if (quantity) {\n        quantity.value = \"0\";\n    }\n\n\n    if (available) {\n\n        available.value = \"0\";\n\n        available.setCustomValidity(\n            \"\"\n        );\n    }\n\n\n    if (condition) {\n        condition.value = \"Baik\";\n    }\n\n\n    if (unit) {\n        unit.value = \"Unit\";\n    }\n\n\n    // =====================================================\n    // SHOW\n    // =====================================================\n\n    modal.classList.add(\n        \"show\"\n    );\n\n\n    document.body.style.overflow =\n        \"hidden\";\n\n\n    // =====================================================\n    // FOCUS\n    // =====================================================\n\n    setTimeout(\n        function () {\n\n            const firstInput =\n                document.getElementById(\n                    \"addItemName\"\n                );\n\n            if (firstInput) {\n                firstInput.focus();\n            }\n\n        },\n        50\n    );\n}\n\n\n// =========================================================\n// OPEN STOCK MODAL\n// =========================================================\n\nfunction openStockModal(button) {\n\n    if (!button) {\n        return;\n    }\n\n    setValue(\n        \"stockItemId\",\n        button.dataset.id\n    );\n\n    setText(\n        \"stockItemCode\",\n        button.dataset.code\n    );\n\n    setText(\n        \"stockItemName\",\n        button.dataset.name\n    );\n\n    setText(\n        \"stockCurrentAvailable\",\n        button.dataset.available || \"0\"\n    );\n\n    setText(\n        \"stockCurrentUnit\",\n        button.dataset.unit || \"Unit\"\n    );\n\n    const quantityInput =\n        document.getElementById(\n            \"stockQuantity\"\n        );\n\n    const remarksInput =\n        document.getElementById(\n            \"stockRemarks\"\n        );\n\n    if (quantityInput) {\n        quantityInput.value = \"\";\n    }\n\n    if (remarksInput) {\n        remarksInput.value = \"\";\n    }\n\n    showModal(\n        \"stockInventoryModal\"\n    );\n\n    setTimeout(\n        function () {\n            if (quantityInput) {\n                quantityInput.focus();\n            }\n        },\n        50\n    );\n}\n\n\n// =========================================================\n// OPEN VIEW MODAL\n// =========================================================\n\nfunction openViewModal(button) {\n\n    if (!button) {\n        return;\n    }\n\n\n    setText(\n        \"viewCode\",\n        button.dataset.code\n    );\n\n    setText(\n        \"viewName\",\n        button.dataset.name\n    );\n\n    setText(\n        \"viewCategory\",\n        button.dataset.category\n    );\n\n    const rawType = String(button.dataset.type || \"\");\n    const normalizedType = rawType.trim().toUpperCase();\n    const displayType = normalizedType === \"CONSUMABLE\"\n        ? \"Barang Guna Habis\"\n        : normalizedType === \"ASSET\"\n            ? \"Aset\"\n            : rawType;\n\n    setText(\n        \"viewType\",\n        displayType\n    );\n\n    setText(\n        \"viewBrand\",\n        button.dataset.brand\n    );\n\n    setText(\n        \"viewColour\",\n        button.dataset.colour\n    );\n\n    setText(\n        \"viewSize\",\n        button.dataset.size\n    );\n\n    setText(\n        \"viewUnit\",\n        button.dataset.unit\n    );\n\n    setText(\n        \"viewQuantity\",\n        button.dataset.quantity\n    );\n\n    setText(\n        \"viewAvailable\",\n        button.dataset.available\n    );\n\n    setText(\n        \"viewCondition\",\n        button.dataset.condition\n    );\n\n    setText(\n        \"viewLocation\",\n        button.dataset.location\n    );\n\n    setText(\n        \"viewStatus\",\n        button.dataset.status\n    );\n\n    setText(\n        \"viewDescription\",\n        button.dataset.description\n    );\n\n\n    showModal(\n        \"viewInventoryModal\"\n    );\n}\n\n\n// =========================================================\n// OPEN EDIT MODAL\n// =========================================================\n\nfunction openEditModal(button) {\n\n    if (!button) {\n        return;\n    }\n\n\n    setValue(\n        \"editId\",\n        button.dataset.id\n    );\n\n    setValue(\n        \"editItemCode\",\n        button.dataset.code\n    );\n\n    setValue(\n        \"editItemName\",\n        button.dataset.name\n    );\n\n    setValue(\n        \"editCategory\",\n        button.dataset.category\n    );\n\n    setValue(\n        \"editItemType\",\n        button.dataset.type\n    );\n\n    setValue(\n        \"editBrand\",\n        button.dataset.brand\n    );\n\n    setValue(\n        \"editColour\",\n        button.dataset.colour\n    );\n\n    setValue(\n        \"editSize\",\n        button.dataset.size\n    );\n\n    setValue(\n        \"editQuantity\",\n        button.dataset.quantity\n    );\n\n    setValue(\n        \"editAvailableQuantity\",\n        button.dataset.available\n    );\n\n    setValue(\n        \"editUnit\",\n        button.dataset.unit\n    );\n\n    setValue(\n        \"editCondition\",\n        button.dataset.condition\n    );\n\n    setValue(\n        \"editLocation\",\n        button.dataset.location\n    );\n\n    setValue(\n        \"editDescription\",\n        button.dataset.description\n    );\n\n\n    // =====================================================\n    // CLEAR VALIDATION\n    // =====================================================\n\n    const editAvailable =\n        document.getElementById(\n            \"editAvailableQuantity\"\n        );\n\n\n    if (editAvailable) {\n\n        editAvailable.setCustomValidity(\n            \"\"\n        );\n    }\n\n\n    showModal(\n        \"editInventoryModal\"\n    );\n\n\n    setTimeout(\n        function () {\n\n            const nameInput =\n                document.getElementById(\n                    \"editItemName\"\n                );\n\n            if (nameInput) {\n\n                nameInput.focus();\n\n                nameInput.select();\n            }\n\n        },\n        50\n    );\n}\n\n\n// =========================================================\n// OPEN DELETE MODAL\n// =========================================================\n\nfunction openDeleteModal(button) {\n\n    if (!button) {\n        return;\n    }\n\n\n    setValue(\n        \"deleteId\",\n        button.dataset.id\n    );\n\n\n    const display =\n        document.getElementById(\n            \"deleteItemDisplay\"\n        );\n\n\n    if (display) {\n\n        const code =\n            cleanDisplayValue(\n                button.dataset.code\n            );\n\n        const name =\n            cleanDisplayValue(\n                button.dataset.name\n            );\n\n\n        let text = \"\";\n\n\n        if (\n            code !== \"-\"\n            &&\n            name !== \"-\"\n        ) {\n\n            text =\n                code\n                + \" - \"\n                + name;\n\n        }\n        else if (name !== \"-\") {\n\n            text = name;\n\n        }\n        else {\n\n            text = code;\n        }\n\n\n        display.textContent =\n            text;\n    }\n\n\n    showModal(\n        \"deleteInventoryModal\"\n    );\n}\n\n\n// =========================================================\n// SHOW MODAL\n// =========================================================\n\nfunction showModal(modalId) {\n\n    const modal =\n        document.getElementById(\n            modalId\n        );\n\n\n    if (!modal) {\n        return;\n    }\n\n\n    modal.classList.add(\n        \"show\"\n    );\n\n\n    document.body.style.overflow =\n        \"hidden\";\n}\n\n\n// =========================================================\n// CLOSE MODAL\n// =========================================================\n\nfunction closeModal(modalId) {\n\n    const modal =\n        document.getElementById(\n            modalId\n        );\n\n\n    if (!modal) {\n        return;\n    }\n\n\n    modal.classList.remove(\n        \"show\"\n    );\n\n\n    // =====================================================\n    // ONLY ENABLE BODY SCROLL IF NO OTHER MODAL IS OPEN\n    // =====================================================\n\n    const remainingModal =\n        document.querySelector(\n            \".inventory-modal.show\"\n        );\n\n\n    if (!remainingModal) {\n\n        document.body.style.overflow =\n            \"\";\n    }\n}\n\n\n// =========================================================\n// SET INPUT VALUE\n// =========================================================\n\nfunction setValue(\n    elementId,\n    value\n) {\n\n    const element =\n        document.getElementById(\n            elementId\n        );\n\n\n    if (!element) {\n        return;\n    }\n\n\n    let cleanValue =\n        value == null\n            ? \"\"\n            : String(value).trim();\n\n\n    // Convert legacy database value \"Good\" to the current Malay value \"Baik\".\n    if (\n        (elementId === \"addCondition\" || elementId === \"editCondition\")\n        &&\n        cleanValue.toLowerCase() === \"good\"\n    ) {\n        cleanValue = \"Baik\";\n    }\n\n\n    // Do not create extra options from old or unexpected database values.\n    // The condition dropdown is limited to Baik, Sederhana and Rosak.\n    if (element.tagName === \"SELECT\") {\n\n        const matchingOption =\n            Array.from(element.options).find(\n                option =>\n                    option.value.toLowerCase() ===\n                    cleanValue.toLowerCase()\n            );\n\n        element.value = matchingOption\n            ? matchingOption.value\n            : \"\";\n\n        return;\n    }\n\n\n    element.value = cleanValue;\n}\n\n\n// =========================================================\n// SET TEXT\n// =========================================================\n\nfunction setText(\n    elementId,\n    value\n) {\n\n    const element =\n        document.getElementById(\n            elementId\n        );\n\n\n    if (!element) {\n        return;\n    }\n\n\n    element.textContent =\n        cleanDisplayValue(\n            value\n        );\n}\n\n\n// =========================================================\n// CLEAN DISPLAY VALUE\n// =========================================================\n\nfunction cleanDisplayValue(value) {\n\n    if (\n        value == null\n        ||\n        String(value).trim() === \"\"\n        ||\n        String(value).trim().toLowerCase()\n            === \"null\"\n        ||\n        String(value).trim().toLowerCase()\n            === \"undefined\"\n    ) {\n\n        return \"-\";\n    }\n\n\n    return String(value).trim();\n}\n\n\n// =========================================================\n// PREVENT NEGATIVE QUANTITY\n// =========================================================\n\ndocument.addEventListener(\n    \"input\",\n    function (event) {\n\n        const target =\n            event.target;\n\n\n        if (\n            target\n            &&\n            target.matches(\n                'input[type=\"number\"]'\n            )\n        ) {\n\n            const value =\n                parseInt(\n                    target.value || \"0\",\n                    10\n                );\n\n\n            if (\n                !Number.isNaN(value)\n                &&\n                value < 0\n            ) {\n\n                target.value = \"0\";\n            }\n        }\n    }\n);\n\n\n// =========================================================\n// FORM SUBMISSION PROTECTION\n// =========================================================\n\ndocument.addEventListener(\n    \"submit\",\n    function (event) {\n\n        const form =\n            event.target;\n\n\n        if (\n            !form\n            ||\n            !form.closest(\n                \".inventory-modal\"\n            )\n        ) {\n\n            return;\n        }\n\n\n        // =====================================================\n        // ADD FORM\n        // =====================================================\n\n        if (\n            form.closest(\n                \"#addInventoryModal\"\n            )\n        ) {\n\n            const totalInput =\n                document.getElementById(\n                    \"addQuantity\"\n                );\n\n            const availableInput =\n                document.getElementById(\n                    \"addAvailableQuantity\"\n                );\n\n\n            if (\n                totalInput\n                &&\n                availableInput\n            ) {\n\n                const total =\n                    parseInt(\n                        totalInput.value || \"0\",\n                        10\n                    );\n\n                const available =\n                    parseInt(\n                        availableInput.value || \"0\",\n                        10\n                    );\n\n\n                if (\n                    available > total\n                ) {\n\n                    event.preventDefault();\n\n\n                    availableInput.setCustomValidity(\n                        \"Kuantiti tersedia tidak boleh melebihi jumlah kuantiti.\"\n                    );\n\n\n                    availableInput.reportValidity();\n\n\n                    return;\n                }\n            }\n        }\n\n\n        // =====================================================\n        // EDIT FORM\n        // =====================================================\n\n        if (\n            form.closest(\n                \"#editInventoryModal\"\n            )\n        ) {\n\n            const totalInput =\n                document.getElementById(\n                    \"editQuantity\"\n                );\n\n            const availableInput =\n                document.getElementById(\n                    \"editAvailableQuantity\"\n                );\n\n\n            if (\n                totalInput\n                &&\n                availableInput\n            ) {\n\n                const total =\n                    parseInt(\n                        totalInput.value || \"0\",\n                        10\n                    );\n\n                const available =\n                    parseInt(\n                        availableInput.value || \"0\",\n                        10\n                    );\n\n\n                if (\n                    available > total\n                ) {\n\n                    event.preventDefault();\n\n\n                    availableInput.setCustomValidity(\n                        \"Kuantiti tersedia tidak boleh melebihi jumlah kuantiti.\"\n                    );\n\n\n                    availableInput.reportValidity();\n\n\n                    return;\n                }\n            }\n        }\n\n\n        // =====================================================\n        // DISABLE SUBMIT BUTTON AFTER VALID SUBMISSION\n        // =====================================================\n\n        if (!event.defaultPrevented) {\n\n            const submitButton =\n                form.querySelector(\n                    'button[type=\"submit\"]'\n                );\n\n\n            if (submitButton) {\n\n                setTimeout(\n                    function () {\n\n                        submitButton.disabled =\n                            true;\n\n                        submitButton.style.opacity =\n                            \".7\";\n\n                        submitButton.style.cursor =\n                            \"not-allowed\";\n\n                    },\n                    20\n                );\n            }\n        }\n    }\n);\n\n\n\n// Export modal functions for the delegated Admin action handler.\nwindow.openAddModal = openAddModal;\nwindow.openStockModal = openStockModal;\nwindow.openViewModal = openViewModal;\nwindow.openEditModal = openEditModal;\nwindow.openDeleteModal = openDeleteModal;\nwindow.closeModal = closeModal;"; } %>

<%@ page contentType="text/html;charset=UTF-8" %><%
    String invRole = (String) session.getAttribute("userRole");
    String invName = (String) session.getAttribute("userName");

    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    if (invRole == null || !"HR".equalsIgnoreCase(invRole.trim())) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }

    if (invName == null || invName.isBlank()) {
        invName = "Pengguna";
    }

    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String,Object>> inventoryItems =
        (java.util.List<java.util.Map<String,Object>>)
        request.getAttribute("items");

    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String,Object>> inventoryCategories =
        (java.util.List<java.util.Map<String,Object>>)
        request.getAttribute("categories");

    @SuppressWarnings("unchecked")
    java.util.Set<String> inventoryTypes =
        (java.util.Set<String>) request.getAttribute("inventoryTypes");

    @SuppressWarnings("unchecked")
    java.util.Set<String> inventoryUnits =
        (java.util.Set<String>) request.getAttribute("inventoryUnits");

    String successMessage = request.getParameter("success");
    String errorMessage = request.getParameter("error");

    java.util.function.Function<Object,String> esc = value -> {
        if (value == null) return "";

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    };

    int totalItems = 0;
    int availableItems = 0;
    int lowStockItems = 0;
    int outStockItems = 0;

    if (inventoryItems != null) {
        totalItems = inventoryItems.size();

        for (java.util.Map<String,Object> item : inventoryItems) {

            String s = item.get("status") == null
                ? ""
                : String.valueOf(item.get("status"));

            if ("AVAILABLE".equalsIgnoreCase(s)) {
                availableItems++;
            }
            else if ("LOW_STOCK".equalsIgnoreCase(s)) {
                lowStockItems++;
            }
            else if ("OUT_OF_STOCK".equalsIgnoreCase(s)) {
                outStockItems++;
            }
        }
    }
%><!DOCTYPE html><html lang="ms"><head><meta charset="UTF-8"><meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
><title>Pengurusan Inventori - PKB</title><link
    rel="stylesheet"
    href="<%= request.getContextPath() %>/css/style.css?v=20260917-inventory-clean"
><style><%= inventoryCss() %></style></head><body><div class="app"><%@ include file="includes/sidebar.jspf" %><main><div class="inventory-page"><div class="inventory-page-header"><div><h1>
                        Pengurusan Inventori
                    </h1><p>
                        Urus, kemas kini dan pantau inventori syarikat.
                    </p></div><div class="inventory-header-right"><a
                        href="<%= request.getContextPath() %>/notifications"
                        class="inventory-notification-btn"
                        title="Notifikasi"
                        aria-label="Notifikasi"
                    ><svg
                            viewBox="0 0 24 24"
                            aria-hidden="true"
                        ><path
                                d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"
                            ></path><path
                                d="M13.73 21a2 2 0 0 1-3.46 0"
                            ></path></svg><%
                            Object unreadObj =
                                session.getAttribute(
                                    "unreadNotificationCount"
                                );

                            int unreadNotificationCount = 0;

                            if (unreadObj != null) {

                                try {

                                    unreadNotificationCount =
                                        Integer.parseInt(
                                            String.valueOf(
                                                unreadObj
                                            )
                                        );

                                }
                                catch (
                                    NumberFormatException ignored
                                ) {

                                    unreadNotificationCount = 0;
                                }
                            }


                            if (
                                unreadNotificationCount > 0
                            ) {
                        %><span
                                class="inventory-notification-badge"
                            ><%= unreadNotificationCount > 99
                                    ? "99+"
                                    : String.valueOf(
                                        unreadNotificationCount
                                    )
                                %></span><%
                            }
                        %></a><div class="inventory-user-card"><div class="inventory-user-avatar"><%
                                String initial = "P";

                                if (
                                    invName != null &&
                                    !invName.isBlank()
                                ) {

                                    initial =
                                        invName
                                            .substring(0,1)
                                            .toUpperCase();
                                }
                            %><%= esc.apply(initial) %></div><div class="inventory-user-info"><span class="inventory-user-name"><%= esc.apply(invName) %></span><span class="inventory-user-role"><%
                                    if (
                                        "HR".equalsIgnoreCase(
                                            invRole
                                        )
                                    ) {
                                %>

                                    Pentadbir Sistem

                                <%
                                    }
                                    else if (
                                        "HOD".equalsIgnoreCase(
                                            invRole
                                        )
                                    ) {
                                %>

                                    Ketua Unit

                                <%
                                    }
                                    else {
                                %>

                                    Staf

                                <%
                                    }
                                %></span></div></div></div></div><%
                if (
                    successMessage != null &&
                    !successMessage.isBlank()
                ) {
            %><div class="inventory-message success"><%
                        if (
                            "added".equalsIgnoreCase(
                                successMessage
                            )
                        ) {

                            out.print(
                                "Barang inventori berjaya ditambah."
                            );

                        }
                        else if (
                            "updated".equalsIgnoreCase(
                                successMessage
                            )
                        ) {

                            out.print(
                                "Maklumat inventori berjaya dikemas kini."
                            );

                        }
                        else if (
                            "deleted".equalsIgnoreCase(
                                successMessage
                            )
                        ) {

                            out.print(
                                "Barang inventori berjaya dipadam."
                            );

                        }
                        else {

                            out.print(
                                "Tindakan berjaya dilaksanakan."
                            );
                        }
                    %></div><%
                }
            %><%
                if (
                    errorMessage != null &&
                    !errorMessage.isBlank()
                ) {
            %><div class="inventory-message error"><%
                        if (
                            "duplicate".equalsIgnoreCase(
                                errorMessage
                            )
                        ) {

                            out.print(
                                "Kod barang telah digunakan."
                            );

                        }
                        else if (
                            "notfound".equalsIgnoreCase(
                                errorMessage
                            )
                        ) {

                            out.print(
                                "Barang inventori tidak ditemui."
                            );

                        }
                        else {

                            out.print(
                                "Tindakan tidak berjaya. Sila cuba semula."
                            );
                        }
                    %></div><%
                }
            %><div class="inventory-summary"><div class="summary-card"><div class="summary-icon"><svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        ><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg></div><div class="summary-info"><span>
                            Jumlah Barang
                        </span><strong><%= totalItems %></strong><small>
                            Rekod inventori
                        </small></div></div><div class="summary-card available"><div class="summary-icon"><svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        ><polyline points="20 6 9 17 4 12"/></svg></div><div class="summary-info"><span>
                            Tersedia
                        </span><strong><%= availableItems %></strong><small>
                            Stok mencukupi
                        </small></div></div><div class="summary-card low"><div class="summary-icon"><svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        ><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></div><div class="summary-info"><span>
                            Stok Rendah
                        </span><strong><%= lowStockItems %></strong><small>
                            Perlu perhatian
                        </small></div></div><div class="summary-card out"><div class="summary-icon"><svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        ><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg></div><div class="summary-info"><span>
                            Kehabisan Stok
                        </span><strong><%= outStockItems %></strong><small>
                            Tiada stok tersedia
                        </small></div></div></div><div class="inventory-card"><div class="inventory-card-header"><div><h2>
                            Senarai Inventori
                        </h2><p>
                            Maklumat stok dan butiran inventori syarikat.
                        </p></div><div class="header-actions"><a
                            href="<%= request.getContextPath() %>/print-inventory-list"
                            class="admin-btn print"
                        ><svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="1.8"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            ><path d="M6 9V3h12v6"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="7"/></svg>

                            Cetak Senarai

                        </a><button
                            type="button"
                            class="admin-btn primary"
                            data-admin-action="add" onclick="openAddModal();"
                        ><svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="1.8"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            ><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>

                            Tambah Barang

                        </button></div></div><div class="inventory-toolbar"><div class="toolbar-left"><div class="search-box"><svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="1.8"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            ><circle
                                    cx="11"
                                    cy="11"
                                    r="8"
                                /><line
                                    x1="21"
                                    y1="21"
                                    x2="16.65"
                                    y2="16.65"
                                /></svg><input
                                type="text"
                                id="inventorySearch"
                                placeholder="Cari kod, barang, jenama..."
                                autocomplete="off"
                            ></div><select
                            id="categoryFilter"
                            class="filter-select"
                        ><option value="">
                                Semua Kategori
                            </option><%
                                if (
                                    inventoryCategories != null
                                ) {

                                    for (
                                        java.util.Map<String,Object>
                                            category :
                                            inventoryCategories
                                    ) {

                                        String categoryName =
                                            category.get("category_name") == null
                                                ? ""
                                                : String.valueOf(
                                                    category.get(
                                                        "category_name"
                                                    )
                                                );
                            %><option
                                    value="<%= esc.apply(categoryName) %>"
                                ><%= esc.apply(categoryName) %></option><%
                                    }
                                }
                            %></select><select
                            id="statusFilter"
                            class="filter-select"
                        ><option value="">
                                Semua Status
                            </option><option value="AVAILABLE">
                                Tersedia
                            </option><option value="LOW_STOCK">
                                Stok Rendah
                            </option><option value="OUT_OF_STOCK">
                                Kehabisan Stok
                            </option></select><button
                            type="button"
                            class="reset-btn"
                            id="resetInventoryFilter"
                        >
                            Reset
                        </button></div><div class="result-count"><strong
                            id="inventoryVisibleCount"
                        ><%= totalItems %></strong>

                        daripada

                        <%= totalItems %>

                        barang

                    </div></div><div class="inventory-table-wrap"><table class="inventory-table"><thead><tr><th>
                                    Kod Barang
                                </th><th>
                                    Nama Barang
                                </th><th>
                                    Kategori
                                </th><th>
                                    Stok
                                </th><th>
                                    Lokasi
                                </th><th>
                                    Status
                                </th><th>
                                    Tindakan
                                </th></tr></thead><tbody id="inventoryTableBody"><%
                            if (
                                inventoryItems != null &&
                                !inventoryItems.isEmpty()
                            ) {

                                for (
                                    java.util.Map<String,Object>
                                        item :
                                        inventoryItems
                                ) {


                                    Object itemId =
                                        item.get("id");


                                    String itemCode =
                                        item.get("item_code") == null
                                            ? "-"
                                            : String.valueOf(
                                                item.get(
                                                    "item_code"
                                                )
                                            );


                                    String itemName =
                                        item.get("item_name") == null
                                            ? "-"
                                            : String.valueOf(
                                                item.get(
                                                    "item_name"
                                                )
                                            );


                                    String category =
                                        item.get("category") == null
                                            ? "-"
                                            : String.valueOf(
                                                item.get(
                                                    "category"
                                                )
                                            );


                                    String itemType =
                                        item.get("item_type") == null
                                            ? ""
                                            : String.valueOf(
                                                item.get(
                                                    "item_type"
                                                )
                                            );


                                    String brand =
                                        item.get("brand") == null
                                            ? ""
                                            : String.valueOf(
                                                item.get(
                                                    "brand"
                                                )
                                            );


                                    String colour =
                                        item.get("color") == null
                                            ? ""
                                            : String.valueOf(
                                                item.get(
                                                    "color"
                                                )
                                            );


                                    String size =
                                        item.get("size") == null
                                            ? ""
                                            : String.valueOf(
                                                item.get(
                                                    "size"
                                                )
                                            );


                                    String unit =
                                        item.get("unit") == null
                                            ? "Unit"
                                            : String.valueOf(
                                                item.get(
                                                    "unit"
                                                )
                                            );


                                    String location =
                                        item.get("location") == null
                                            ? "-"
                                            : String.valueOf(
                                                item.get(
                                                    "location"
                                                )
                                            );


                                    String condition =
                                        item.get("item_condition") == null
                                            ? ""
                                            : String.valueOf(
                                                item.get(
                                                    "item_condition"
                                                )
                                            );


                                    String description =
                                        item.get("description") == null
                                            ? ""
                                            : String.valueOf(
                                                item.get(
                                                    "description"
                                                )
                                            );


                                    String status =
                                        item.get("status") == null
                                            ? ""
                                            : String.valueOf(
                                                item.get(
                                                    "status"
                                                )
                                            );


                                    Object quantity =
                                        item.get("quantity");


                                    Object availableQuantity =
                                        item.get(
                                            "available_quantity"
                                        );


                                    String statusText =
                                        status;


                                    if (
                                        "AVAILABLE".equalsIgnoreCase(
                                            status
                                        )
                                    ) {

                                        statusText =
                                            "Tersedia";

                                    }
                                    else if (
                                        "LOW_STOCK".equalsIgnoreCase(
                                            status
                                        )
                                    ) {

                                        statusText =
                                            "Stok Rendah";

                                    }
                                    else if (
                                        "OUT_OF_STOCK".equalsIgnoreCase(
                                            status
                                        )
                                    ) {

                                        statusText =
                                            "Kehabisan Stok";
                                    }


                                    StringBuilder searchable =
                                        new StringBuilder();


                                    searchable
                                        .append(itemCode)
                                        .append(" ")
                                        .append(itemName)
                                        .append(" ")
                                        .append(category)
                                        .append(" ")
                                        .append(itemType)
                                        .append(" ")
                                        .append(brand)
                                        .append(" ")
                                        .append(colour)
                                        .append(" ")
                                        .append(size)
                                        .append(" ")
                                        .append(location)
                                        .append(" ")
                                        .append(condition)
                                        .append(" ")
                                        .append(description);
                        %><tr
                                class="inventory-data-row"
                                data-category="<%= esc.apply(category) %>"
                                data-status="<%= esc.apply(status) %>"
                                data-search="<%= esc.apply(
                                    searchable
                                        .toString()
                                        .toLowerCase()
                                ) %>"
                            ><td><span class="item-code"><%= esc.apply(
                                            itemCode
                                        ) %></span></td><td><div class="item-info"><span class="item-name"><%= esc.apply(
                                                itemName
                                            ) %></span><div class="item-meta"><%
                                                if (
                                                    brand != null &&
                                                    !brand.isBlank()
                                                ) {
                                            %><span><%= esc.apply(
                                                        brand
                                                    ) %></span><%
                                                }
                                            %><%
                                                if (
                                                    size != null &&
                                                    !size.isBlank()
                                                ) {
                                            %><span><%= esc.apply(
                                                        size
                                                    ) %></span><%
                                                }
                                            %><% if (colour != null && !colour.isBlank()) { %><span><%= esc.apply(colour) %></span><% } %></div></div></td><td><%= esc.apply(
                                        category
                                    ) %></td><td><div class="stock-info"><strong><%= esc.apply(
                                                availableQuantity
                                            ) %></strong><span class="stock-unit"><%= esc.apply(
                                                unit
                                            ) %></span><small>

                                            Jumlah:
                                            <%= esc.apply(
                                                quantity
                                            ) %></small></div></td><td><%= esc.apply(
                                        location
                                    ) %></td><td><span
                                        class="inventory-status <%= esc.apply(status) %>"
                                    ><%= esc.apply(
                                            statusText
                                        ) %></span></td><td><div class="action-group"><button
                                            type="button"
                                            class="table-btn stock"
                                            data-id="<%= esc.apply(itemId) %>"
                                            data-code="<%= esc.apply(itemCode) %>"
                                            data-name="<%= esc.apply(itemName) %>"
                                            data-available="<%= esc.apply(availableQuantity) %>"
                                            data-unit="<%= esc.apply(unit) %>"
                                            data-admin-action="stock" onclick="openStockModal(this);"
                                        >
                                            + Stok
                                        </button><button
                                            type="button"
                                            class="table-btn view"

                                            data-id="<%= esc.apply(itemId) %>"

                                            data-code="<%= esc.apply(itemCode) %>"

                                            data-name="<%= esc.apply(itemName) %>"

                                            data-category="<%= esc.apply(category) %>"

                                            data-type="<%= esc.apply(itemType) %>"

                                            data-brand="<%= esc.apply(brand) %>"

                                            data-colour="<%= esc.apply(colour) %>"

                                            data-size="<%= esc.apply(size) %>"

                                            data-quantity="<%= esc.apply(quantity) %>"

                                            data-available="<%= esc.apply(availableQuantity) %>"

                                            data-unit="<%= esc.apply(unit) %>"

                                            data-condition="<%= esc.apply(condition) %>"

                                            data-location="<%= esc.apply(location) %>"

                                            data-description="<%= esc.apply(description) %>"

                                            data-status="<%= esc.apply(statusText) %>"

                                            data-admin-action="view" onclick="openViewModal(this);"
                                        >

                                            Lihat

                                        </button><button
                                            type="button"
                                            class="table-btn edit"

                                            data-id="<%= esc.apply(itemId) %>"

                                            data-code="<%= esc.apply(itemCode) %>"

                                            data-name="<%= esc.apply(itemName) %>"

                                            data-category="<%= esc.apply(category) %>"

                                            data-type="<%= esc.apply(itemType) %>"

                                            data-brand="<%= esc.apply(brand) %>"

                                            data-colour="<%= esc.apply(colour) %>"

                                            data-size="<%= esc.apply(size) %>"

                                            data-quantity="<%= esc.apply(quantity) %>"

                                            data-available="<%= esc.apply(availableQuantity) %>"

                                            data-unit="<%= esc.apply(unit) %>"

                                            data-condition="<%= esc.apply(condition) %>"

                                            data-location="<%= esc.apply(location) %>"

                                            data-description="<%= esc.apply(description) %>"

                                            data-admin-action="edit" onclick="openEditModal(this);"
                                        >

                                            Kemaskini

                                        </button><button
                                            type="button"
                                            class="table-btn delete"

                                            data-id="<%= esc.apply(itemId) %>"

                                            data-code="<%= esc.apply(itemCode) %>"

                                            data-name="<%= esc.apply(itemName) %>"

                                            data-admin-action="delete" onclick="openDeleteModal(this);"
                                        >

                                            Padam

                                        </button></div></td></tr><%
                                }
                            }
                            else {
                        %><tr class="empty-row"><td colspan="7"><strong>
                                        Tiada inventori ditemui
                                    </strong><span>
                                        Tambah barang inventori untuk memulakan pengurusan stok.
                                    </span></td></tr><%
                            }
                        %></tbody></table></div><div
                    id="inventoryNoResult"
                    class="no-result"
                >

                    Tiada barang yang sepadan dengan carian atau penapis yang dipilih.

                </div></div></div></main></div><div
    id="addInventoryModal"
    class="inventory-modal"
><div class="modal-card large"><div class="modal-header"><div><h3>
                    Tambah Barang Inventori
                </h3><p>
                    Masukkan maklumat barang inventori baharu.
                </p></div><button
                type="button"
                class="modal-close"
                onclick="closeModal('addInventoryModal')"
                aria-label="Tutup"
            >
                &times;
            </button></div><form
            action="<%= request.getContextPath() %>/inventory-admin"
            method="post"
            autocomplete="off"
            style="display:flex; flex-direction:column; min-height:0; flex:1; overflow:hidden;"
        ><input
                type="hidden"
                name="action"
                value="add"
            ><div class="modal-body"><div class="form-grid"><div class="form-group"><label>
                            Kod Barang
                        </label><input
                            type="text"
                            class="form-control"
                            value="Dijana secara automatik"
                            readonly
                            tabindex="-1"
                            style="background:#f6f7f9; color:#7b8493; cursor:not-allowed;"
                        ><span class="form-help">
                            Kod barang akan dijana secara automatik mengikut kategori selepas disimpan.
                        </span></div><div class="form-group"><label for="addItemName">
                            Nama Barang
                        </label><input
                            type="text"
                            id="addItemName"
                            name="item_name"
                            class="form-control"
                            placeholder="Nama barang"
                            required
                        ></div><div class="form-group"><label for="addCategory">
                            Kategori
                        </label><select
                            id="addCategory"
                            name="category"
                            class="form-control"
                            required
                        ><option value="">
                                -- Pilih Kategori --
                            </option><option value="__NEW__">
                                + Tambah Kategori Baharu
                            </option><%
                                if (inventoryCategories != null) {

                                    for (
                                        java.util.Map<String,Object>
                                            category :
                                            inventoryCategories
                                    ) {

                                        String categoryName =
                                            category.get("category_name") == null
                                                ? ""
                                                : String.valueOf(
                                                    category.get(
                                                        "category_name"
                                                    )
                                                );
                            %><option
                                    value="<%= esc.apply(categoryName) %>"
                                ><%= esc.apply(categoryName) %></option><%
                                    }
                                }
                            %></select><div class="new-option-field" id="newCategoryGroup" style="display:none; margin-top:8px;"><label for="newCategoryName">
                            Nama Kategori Baharu
                        </label><input
                            type="text"
                            id="newCategoryName"
                            name="new_category_name"
                            class="form-control"
                            placeholder="Contoh: Kertas, Peralatan Komputer, Fail"
                        ><span class="form-help">
                            Kategori dan prefix Kod Barang akan dijana secara automatik apabila barang disimpan.
                        </span></div></div><div class="form-group"><label for="addItemType">
                            Jenis
                            <span class="optional">
                                (Pilihan)
                            </span></label><select
                            id="addItemType"
                            name="item_type"
                            class="form-control"
                            required
                        ><option value="">-- Pilih Jenis --</option><option value="CONSUMABLE">Barang Guna Habis</option><option value="ASSET">Aset</option><% if (inventoryTypes != null) { for (String savedType : inventoryTypes) { if (!"ASSET".equalsIgnoreCase(savedType) && !"CONSUMABLE".equalsIgnoreCase(savedType)) { %><option value="<%= esc.apply(savedType) %>"><%= esc.apply(savedType) %></option><% } } } %><option value="__NEW__">+ Tambah Jenis Baharu</option></select><div class="new-option-field" id="addNewTypeGroup" style="display:none; margin-top:8px;"><label for="addNewTypeName">Nama Jenis Baharu</label><input type="text" id="addNewTypeName" name="new_item_type" class="form-control" placeholder="Masukkan jenis baharu"></div></div><div class="form-group"><label for="addBrand">
                            Jenama
                            <span class="optional">
                                (Pilihan)
                            </span></label><input
                            type="text"
                            id="addBrand"
                            name="brand"
                            class="form-control"
                            placeholder="Contoh: Artline"
                        ></div><div class="form-group"><label for="addColour">
                            Warna
                            <span class="optional">
                                (Pilihan)
                            </span></label><input
                            type="text"
                            id="addColour"
                            name="color"
                            class="form-control"
                            placeholder="Contoh: Hitam"
                        ></div><div class="form-group"><label for="addSize">
                            Saiz
                            <span class="optional">
                                (Pilihan)
                            </span></label><input
                            type="text"
                            id="addSize"
                            name="size"
                            class="form-control"
                            placeholder="Contoh: 25mm"
                        ></div><div class="form-group"><label for="addUnit">
                            Unit
                        </label><select
                            id="addUnit"
                            name="unit"
                            class="form-control"
                            required
                        ><option value="Unit">Unit</option><option value="Box">Box</option><option value="Pek">Pek</option><option value="Botol">Botol</option><option value="Set">Set</option><option value="Roll">Roll</option><option value="Buku">Buku</option><% if (inventoryUnits != null) { for (String savedUnit : inventoryUnits) { if (!java.util.Arrays.asList("Unit", "Box", "Pek", "Botol", "Set", "Roll", "Buku").contains(savedUnit)) { %><option value="<%= esc.apply(savedUnit) %>"><%= esc.apply(savedUnit) %></option><% } } } %><option value="__NEW__">+ Tambah Unit Baharu</option></select><div class="new-option-field" id="addNewUnitGroup" style="display:none; margin-top:8px;"><label for="addNewUnitName">Nama Unit Baharu</label><input type="text" id="addNewUnitName" name="new_unit" class="form-control" placeholder="Masukkan unit baharu"></div></div><div class="form-group"><label for="addQuantity">
                            Jumlah Kuantiti
                        </label><input
                            type="number"
                            id="addQuantity"
                            name="quantity"
                            class="form-control"
                            min="0"
                            value="0"
                            required
                        ></div><div class="form-group"><label for="addAvailableQuantity">
                            Kuantiti Tersedia
                        </label><input
                            type="number"
                            id="addAvailableQuantity"
                            name="available_quantity"
                            class="form-control"
                            min="0"
                            value="0"
                            required
                        ><span class="form-help">
                            Kuantiti tersedia tidak boleh melebihi jumlah kuantiti.
                        </span></div><div class="form-group"><label for="addCondition">
                            Keadaan Barang
                        </label><select
                            id="addCondition"
                            name="item_condition"
                            class="form-control"
                        ><option value="Baik">
                                Baik
                            </option><option value="Sederhana">
                                Sederhana
                            </option><option value="Rosak">
                                Rosak
                            </option></select></div><div class="form-group"><label for="addLocation">
                            Lokasi
                            <span class="optional">
                                (Pilihan)
                            </span></label><input
                            type="text"
                            id="addLocation"
                            name="location"
                            class="form-control"
                            placeholder="Contoh: Stor Utama"
                        ></div><div class="form-group full"><label for="addDescription">
                            Keterangan
                            <span class="optional">
                                (Pilihan)
                            </span></label><textarea
                            id="addDescription"
                            name="description"
                            class="form-control"
                            placeholder="Masukkan keterangan tambahan jika perlu."
                        ></textarea></div></div></div><div class="modal-footer"><button
                    type="button"
                    class="modal-btn cancel"
                    onclick="closeModal('addInventoryModal')"
                >
                    Batal
                </button><button
                    type="submit"
                    class="modal-btn save"
                >
                    Simpan Barang
                </button></div></form></div></div><div
    id="editInventoryModal"
    class="inventory-modal"
><div class="modal-card large"><div class="modal-header"><div><h3>
                    Kemaskini Barang Inventori
                </h3><p>
                    Kemaskini maklumat dan stok barang inventori.
                </p></div><button
                type="button"
                class="modal-close"
                onclick="closeModal('editInventoryModal')"
                aria-label="Tutup"
            >
                &times;
            </button></div><form
            action="<%= request.getContextPath() %>/inventory-admin"
            method="post"
            autocomplete="off"
        ><input
                type="hidden"
                name="action"
                value="edit"
            ><input
                type="hidden"
                id="editId"
                name="id"
            ><div class="modal-body"><div class="form-grid"><div class="form-group"><label for="editItemCode">
                            Kod Barang
                        </label><input
                            type="text"
                            id="editItemCode"
                            name="item_code"
                            class="form-control"
                            required
                        ></div><div class="form-group"><label for="editItemName">
                            Nama Barang
                        </label><input
                            type="text"
                            id="editItemName"
                            name="item_name"
                            class="form-control"
                            required
                        ></div><div class="form-group"><label for="editCategory">
                            Kategori
                        </label><select
                            id="editCategory"
                            name="category"
                            class="form-control"
                            required
                        ><option value="">
                                -- Pilih Kategori --
                            </option><option value="__NEW__">+ Tambah Kategori Baharu</option><%
                                if (inventoryCategories != null) {

                                    for (
                                        java.util.Map<String,Object>
                                            category :
                                            inventoryCategories
                                    ) {

                                        String categoryName =
                                            category.get("category_name") == null
                                                ? ""
                                                : String.valueOf(
                                                    category.get(
                                                        "category_name"
                                                    )
                                                );
                            %><option
                                    value="<%= esc.apply(categoryName) %>"
                                ><%= esc.apply(categoryName) %></option><%
                                    }
                                }
                            %></select><div class="new-option-field" id="editNewCategoryGroup" style="display:none; margin-top:8px;"><label for="editNewCategoryName">Nama Kategori Baharu</label><input type="text" id="editNewCategoryName" name="new_category_name" class="form-control" placeholder="Masukkan kategori baharu"></div></div><div class="form-group"><label for="editItemType">
                            Jenis
                            <span class="optional">
                                (Pilihan)
                            </span></label><select
                            id="editItemType"
                            name="item_type"
                            class="form-control"
                            required
                        ><option value="">-- Pilih Jenis --</option><option value="CONSUMABLE">Barang Guna Habis</option><option value="ASSET">Aset</option><% if (inventoryTypes != null) { for (String savedType : inventoryTypes) { if (!"ASSET".equalsIgnoreCase(savedType) && !"CONSUMABLE".equalsIgnoreCase(savedType)) { %><option value="<%= esc.apply(savedType) %>"><%= esc.apply(savedType) %></option><% } } } %><option value="__NEW__">+ Tambah Jenis Baharu</option></select><div class="new-option-field" id="editNewTypeGroup" style="display:none; margin-top:8px;"><label for="editNewTypeName">Nama Jenis Baharu</label><input type="text" id="editNewTypeName" name="new_item_type" class="form-control" placeholder="Masukkan jenis baharu"></div></div><div class="form-group"><label for="editBrand">
                            Jenama
                            <span class="optional">
                                (Pilihan)
                            </span></label><input
                            type="text"
                            id="editBrand"
                            name="brand"
                            class="form-control"
                        ></div><div class="form-group"><label for="editColour">
                            Warna
                            <span class="optional">
                                (Pilihan)
                            </span></label><input
                            type="text"
                            id="editColour"
                            name="color"
                            class="form-control"
                        ></div><div class="form-group"><label for="editSize">
                            Saiz
                            <span class="optional">
                                (Pilihan)
                            </span></label><input
                            type="text"
                            id="editSize"
                            name="size"
                            class="form-control"
                        ></div><div class="form-group"><label for="editUnit">
                            Unit
                        </label><select
                            id="editUnit"
                            name="unit"
                            class="form-control"
                            required
                        ><option value="Unit">Unit</option><option value="Box">Box</option><option value="Pek">Pek</option><option value="Botol">Botol</option><option value="Set">Set</option><option value="Roll">Roll</option><option value="Buku">Buku</option><% if (inventoryUnits != null) { for (String savedUnit : inventoryUnits) { if (!java.util.Arrays.asList("Unit", "Box", "Pek", "Botol", "Set", "Roll", "Buku").contains(savedUnit)) { %><option value="<%= esc.apply(savedUnit) %>"><%= esc.apply(savedUnit) %></option><% } } } %><option value="__NEW__">+ Tambah Unit Baharu</option></select><div class="new-option-field" id="editNewUnitGroup" style="display:none; margin-top:8px;"><label for="editNewUnitName">Nama Unit Baharu</label><input type="text" id="editNewUnitName" name="new_unit" class="form-control" placeholder="Masukkan unit baharu"></div></div><div class="form-group"><label for="editQuantity">
                            Jumlah Kuantiti
                        </label><input
                            type="number"
                            id="editQuantity"
                            name="quantity"
                            class="form-control"
                            min="0"
                            required
                        ></div><div class="form-group"><label for="editAvailableQuantity">
                            Kuantiti Tersedia
                        </label><input
                            type="number"
                            id="editAvailableQuantity"
                            name="available_quantity"
                            class="form-control"
                            min="0"
                            required
                        ><span class="form-help">
                            Kuantiti tersedia tidak boleh melebihi jumlah kuantiti.
                        </span></div><div class="form-group"><label for="editCondition">
                            Keadaan Barang
                        </label><select
                            id="editCondition"
                            name="item_condition"
                            class="form-control"
                        ><option value="Baik">
                                Baik
                            </option><option value="Sederhana">
                                Sederhana
                            </option><option value="Rosak">
                                Rosak
                            </option></select></div><div class="form-group"><label for="editLocation">
                            Lokasi
                            <span class="optional">
                                (Pilihan)
                            </span></label><input
                            type="text"
                            id="editLocation"
                            name="location"
                            class="form-control"
                        ></div><div class="form-group full"><label for="editDescription">
                            Keterangan
                            <span class="optional">
                                (Pilihan)
                            </span></label><textarea
                            id="editDescription"
                            name="description"
                            class="form-control"
                        ></textarea></div></div></div><div class="modal-footer"><button
                    type="button"
                    class="modal-btn cancel"
                    onclick="closeModal('editInventoryModal')"
                >
                    Batal
                </button><button
                    type="submit"
                    class="modal-btn save"
                >
                    Simpan Perubahan
                </button></div></form></div></div><div
    id="viewInventoryModal"
    class="inventory-modal"
><div class="modal-card"><div class="modal-header"><div><h3>
                    Butiran Inventori
                </h3><p>
                    Maklumat lengkap barang yang dipilih.
                </p></div><button
                type="button"
                class="modal-close"
                onclick="closeModal('viewInventoryModal')"
                aria-label="Tutup"
            >
                &times;
            </button></div><div class="modal-body"><div class="detail-grid"><div class="detail-item"><span>
                        Kod Barang
                    </span><strong id="viewCode">
                        -
                    </strong></div><div class="detail-item"><span>
                        Nama Barang
                    </span><strong id="viewName">
                        -
                    </strong></div><div class="detail-item"><span>
                        Kategori
                    </span><strong id="viewCategory">
                        -
                    </strong></div><div class="detail-item"><span>
                        Jenis
                    </span><strong id="viewType">
                        -
                    </strong></div><div class="detail-item"><span>
                        Jenama
                    </span><strong id="viewBrand">
                        -
                    </strong></div><div class="detail-item"><span>
                        Warna
                    </span><strong id="viewColour">
                        -
                    </strong></div><div class="detail-item"><span>
                        Saiz
                    </span><strong id="viewSize">
                        -
                    </strong></div><div class="detail-item"><span>
                        Unit
                    </span><strong id="viewUnit">
                        -
                    </strong></div><div class="detail-item"><span>
                        Jumlah Kuantiti
                    </span><strong id="viewQuantity">
                        -
                    </strong></div><div class="detail-item"><span>
                        Kuantiti Tersedia
                    </span><strong id="viewAvailable">
                        -
                    </strong></div><div class="detail-item"><span>
                        Keadaan Barang
                    </span><strong id="viewCondition">
                        -
                    </strong></div><div class="detail-item"><span>
                        Lokasi
                    </span><strong id="viewLocation">
                        -
                    </strong></div><div class="detail-item full"><span>
                        Status
                    </span><strong id="viewStatus">
                        -
                    </strong></div><div class="detail-item full"><span>
                        Keterangan
                    </span><strong id="viewDescription">
                        -
                    </strong></div></div></div><div class="modal-footer"><button
                type="button"
                class="modal-btn cancel"
                onclick="closeModal('viewInventoryModal')"
            >
                Tutup
            </button></div></div></div><div
    id="stockInventoryModal"
    class="inventory-modal"
><div class="modal-card"><div class="modal-header"><div><h3>Tambah Stok Inventori</h3><p>Masukkan kuantiti stok baharu untuk barang yang dipilih.</p></div><button
                type="button"
                class="modal-close"
                onclick="closeModal('stockInventoryModal')"
                aria-label="Tutup"
            >
                &times;
            </button></div><form
            action="<%= request.getContextPath() %>/inventory-admin"
            method="post"
            autocomplete="off"
        ><input type="hidden" name="action" value="stock-in"><input type="hidden" id="stockItemId" name="item_id"><div class="modal-body"><div class="detail-grid" style="margin-bottom:18px;"><div class="detail-item"><span>Kod Barang</span><strong id="stockItemCode">-</strong></div><div class="detail-item"><span>Nama Barang</span><strong id="stockItemName">-</strong></div><div class="detail-item"><span>Stok Semasa</span><strong><span id="stockCurrentAvailable">0</span><span id="stockCurrentUnit">Unit</span></strong></div></div><div class="form-grid"><div class="form-group full"><label for="stockQuantity">
                            Kuantiti Stok Masuk
                        </label><input
                            type="number"
                            id="stockQuantity"
                            name="quantity"
                            class="form-control"
                            min="1"
                            step="1"
                            placeholder="Contoh: 10"
                            required
                        ></div><div class="form-group full"><label for="stockRemarks">
                            Catatan
                            <span class="optional">(Pilihan)</span></label><textarea
                            id="stockRemarks"
                            name="remarks"
                            class="form-control"
                            rows="3"
                            placeholder="Contoh: Stok baharu diterima daripada pembekal"
                        ></textarea></div></div></div><div class="modal-footer"><button
                    type="button"
                    class="modal-btn cancel"
                    onclick="closeModal('stockInventoryModal')"
                >
                    Batal
                </button><button
                    type="submit"
                    class="modal-btn save"
                >
                    Tambah Stok
                </button></div></form></div></div><div
    id="deleteInventoryModal"
    class="inventory-modal"
><div class="modal-card"><div class="modal-header"><div><h3>
                    Padam Barang Inventori
                </h3><p>
                    Sahkan tindakan sebelum barang dipadam.
                </p></div><button
                type="button"
                class="modal-close"
                onclick="closeModal('deleteInventoryModal')"
                aria-label="Tutup"
            >
                &times;
            </button></div><form
            action="<%= request.getContextPath() %>/inventory-admin"
            method="post"
        ><input
                type="hidden"
                name="action"
                value="delete"
            ><input
                type="hidden"
                id="deleteId"
                name="id"
            ><div class="modal-body"><div class="delete-warning"><div class="delete-warning-icon"><svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        ><path
                                d="M3 6h18"
                            /><path
                                d="M8 6V4h8v2"
                            /><path
                                d="M19 6l-1 14H6L5 6"
                            /><line
                                x1="10"
                                y1="11"
                                x2="10"
                                y2="16"
                            /><line
                                x1="14"
                                y1="11"
                                x2="14"
                                y2="16"
                            /></svg></div><div><strong>
                            Adakah anda pasti?
                        </strong><p>

                            Barang

                            <strong
                                id="deleteItemDisplay"
                                style="
                                    display:inline;
                                    margin:0;
                                "
                            >
                                -
                            </strong>

                            akan dipadam daripada senarai inventori.

                            Tindakan ini tidak boleh dibatalkan.

                        </p></div></div></div><div class="modal-footer"><button
                    type="button"
                    class="modal-btn cancel"
                    onclick="closeModal('deleteInventoryModal')"
                >
                    Batal
                </button><button
                    type="submit"
                    class="modal-btn save"
                    style="
                        background:#a8323e;
                        border-color:#a8323e;
                    "
                >
                    Ya, Padam
                </button></div></form></div></div><script>
(function () {
    function toggleField(selectId, groupId, inputId) {
        var select = document.getElementById(selectId);
        var group = document.getElementById(groupId);
        var input = document.getElementById(inputId);
        if (!select || !group || !input) return;
        function update() {
            var isNew = select.value === '__NEW__';
            group.style.display = isNew ? 'block' : 'none';
            input.required = isNew;
            if (!isNew) input.value = '';
        }
        select.addEventListener('change', update);
        update();
    }
    document.addEventListener('DOMContentLoaded', function () {
        toggleField('addCategory', 'newCategoryGroup', 'newCategoryName');
        toggleField('editCategory', 'editNewCategoryGroup', 'editNewCategoryName');
        toggleField('addItemType', 'addNewTypeGroup', 'addNewTypeName');
        toggleField('editItemType', 'editNewTypeGroup', 'editNewTypeName');
        toggleField('addUnit', 'addNewUnitGroup', 'addNewUnitName');
        toggleField('editUnit', 'editNewUnitGroup', 'editNewUnitName');
    });


})();
</script><script><%= inventoryJs() %></script></body></html>
