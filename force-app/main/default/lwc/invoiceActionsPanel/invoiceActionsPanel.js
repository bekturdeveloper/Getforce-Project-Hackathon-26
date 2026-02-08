import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { updateRecord } from "lightning/uiRecordApi";
import ID_FIELD from "@salesforce/schema/Invoice__c.Id";
import STATUS_FIELD from "@salesforce/schema/Invoice__c.Status__c";

export default class InvoiceActionsPanel extends LightningElement {
    @api recordId;
    @track pdfUrl;

    // Toast helper
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    // ✅ Update Status Field in Salesforce
    updateStatus(newStatus) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS_FIELD.fieldApiName] = newStatus;

        updateRecord({ fields })
            .then(() => {
                this.showToast(
                    "Success 🎉",
                    `Invoice marked as ${newStatus}`,
                    "success"
                );
            })
            .catch((error) => {
                this.showToast(
                    "Error",
                    error.body.message,
                    "error"
                );
            });
    }

    // Generate PDF link
    handleGeneratePdf() {
        this.pdfUrl = "/apex/InvoicePdf?id=" + this.recordId;

        this.showToast(
            "PDF Ready",
            "Invoice PDF generated successfully!",
            "info"
        );
    }

    // ✅ Button Actions
    handleMarkSent() {
        this.updateStatus("Sent");
    }

    handleMarkPaid() {
        this.updateStatus("Paid");
    }
}