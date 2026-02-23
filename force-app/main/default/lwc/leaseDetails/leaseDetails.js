import { LightningElement, api } from 'lwc';
import hasOverlappingLease from '@salesforce/apex/LeaseWizardController.hasOverlappingLease';
import ASSET_CONFLICT from '@salesforce/label/c.RenterOps_LeaseWizard_AssetConflict';

export default class LeaseDetails extends LightningElement {

    assetConflictMessage = ASSET_CONFLICT;
    @api assetId; // passed from parent

    startDate;
    endDate;
    monthlyRent;
    dueDay;
    errorMessage;

    handleChange(event) {
        this.errorMessage = null;

        const field = event.target.name;
        this[field] = event.target.value;

        this.validateClientSide();
    }

    validateClientSide() {
        if (this.startDate && this.endDate && this.startDate > this.endDate) {
            this.errorMessage = 'Start Date must be before or equal to End Date';
            return false;
        }

        if (this.dueDay && (this.dueDay < 1 || this.dueDay > 28)) {
            this.errorMessage = 'Due Day must be between 1 and 28';
            return false;
        }

        return true;
    }

    @api
    async validateAndSend() {
        if (!this.validateClientSide()) {
            return false;
        }

        const hasConflict = await hasOverlappingLease({
            assetId: this.assetId,
            startDate: this.startDate,
            endDate: this.endDate
        });

        if (hasConflict) {
            this.errorMessage = ASSET_CONFLICT;
            return false;
        }

        // Send valid data to parent
        this.dispatchEvent(
            new CustomEvent('leasedetailsvalid', {
                detail: {
                    startDate: this.startDate,
                    endDate: this.endDate,
                    monthlyRent: this.monthlyRent,
                    dueDay: this.dueDay,
                    status: 'Draft'
                }
            })
        );

        return true;
    }
}