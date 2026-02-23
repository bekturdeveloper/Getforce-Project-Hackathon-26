import { LightningElement, api, wire } from 'lwc';
import getAsset from '@salesforce/apex/RentalAssetOperationsController.getAsset';
import getActiveLease from '@salesforce/apex/RentalAssetOperationsController.getActiveLease';
import getOpenMaintenance from '@salesforce/apex/RentalAssetOperationsController.getOpenMaintenance';
import { NavigationMixin } from 'lightning/navigation';

export default class RentalAssetOperationsPanel extends NavigationMixin(LightningElement) {

    @api recordId;

    asset;
    lease;
    maintenance;

    columns = [
    { label: 'Category', fieldName: 'Category__c' },
    { label: 'Priority', fieldName: 'Priority__c' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Requested', fieldName: 'RequestedAt__c', type: 'date' },
    { label: 'Vendor', fieldName: 'VendorName__c' },
    { label: 'Cost', fieldName: 'CostEstimate__c', type: 'currency' }
];


    @wire(getAsset, { recordId: '$recordId' })
    wiredAsset({data}) {
        if (data) this.asset = data;
    }

    @wire(getActiveLease, { assetId: '$recordId' })
    wiredLease({data}) {
        if (data) this.lease = data;
    }

    @wire(getOpenMaintenance, { assetId: '$recordId' })
    wiredMaintenance({data}) {
    if (data) {
        this.maintenance = data;
    }
}

    handleNewMaintenance() {

        let defaults = `RentalAsset__c=${this.recordId}`;

        if (this.lease) {
            defaults += `,Lease__c=${this.lease.Id}`;
            defaults += `,Tenant__c=${this.lease.Tenant__c}`;
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'MaintenanceRequest__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaults
            }
        });
    }
}
