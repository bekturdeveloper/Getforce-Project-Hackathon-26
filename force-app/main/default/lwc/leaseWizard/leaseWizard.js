import { LightningElement, track } from 'lwc';
import createLease from '@salesforce/apex/LeaseWizardController.createLease';
import { NavigationMixin } from 'lightning/navigation';

export default class LeaseWizard extends NavigationMixin(LightningElement) {

    // Step control
    @track currentStep = 1;

    // Data collected from steps
    tenantId;
    tenantName;
    assetId;
    assetName;
    leaseData;
    errorMessage;

    // ---- Step getters ----
    get currentStepString() {
        return String(this.currentStep);
    }
    get isStep1() {
        return this.currentStep === 1;
    }

    get isStep2() {
        return this.currentStep === 2;
    }

    get isStep3() {
        return this.currentStep === 3;
    }

    get isStep4() {
        return this.currentStep === 4;
    }

    // ---- Navigation ----
    async handleNext() {
        if (this.currentStep === 3) {
            const cmp = this.template.querySelector('c-lease-details');
            const isValid = await cmp.validateAndSend();
            if (!isValid) {
                return;
            }
        }

        if (this.validateCurrentStep()) {
            this.currentStep++;
        }
    }

    handleBack() {
        this.currentStep--;
    }

    // ---- Event handlers from child components ----
handleTenantSelected(event) {
    this.tenantId = event.detail.tenantId;
    this.tenantName = event.detail.tenantName;
}

handleAssetSelected(event) {
    this.assetId = event.detail.assetId;
    this.assetName = event.detail.assetName;
}
    
    
handleLeaseDetails(event) {
    this.leaseData = event.detail;
}
async handleCreateLease() {
    this.errorMessage = null;

    try {
        const leaseId = await createLease({
            tenantId: this.tenantId,
            assetId: this.assetId,
            startDate: this.leaseData.startDate,
            endDate: this.leaseData.endDate,
            monthlyRent: this.leaseData.monthlyRent,
            dueDay: this.leaseData.dueDay
        });

        // Redirect to newly created Lease record
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: leaseId,
                objectApiName: 'Lease__c',
                actionName: 'view'
            }
        });

    } catch (error) {
        this.errorMessage = error.body ? error.body.message : 'Failed to create Lease';
    }
}

// ---- Validation ----
validateCurrentStep() {
        if (this.isStep1 && !this.tenantId) {
            this.showError('Please select a tenant');
            return false;
        }

        if (this.isStep2 && !this.assetId) {
            this.showError('Please select a rental asset');
            return false;
        }

        return true;
    }

    // ---- Helpers ----
    showError(message) {
        // keep simple for now (toast later)
        alert(message);
    }
}

