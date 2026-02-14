import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getMaintenanceData from '@salesforce/apex/MaintenanceConsoleController.getMaintenanceData';
import updateStatus from '@salesforce/apex/MaintenanceConsoleController.updateStatus';

export default class MaintenanceConsoleConsole extends NavigationMixin(LightningElement) {
    @track status = 'All';
    @track priority = 'All';
    @track category = 'All';
    @track searchKey = '';
    
    wiredDataResult;
    requests = [];
    counts = { New: 0, InProgress: 0, Closed: 0 };

   
    statusOptions = [ {label: 'All', value: 'All'}, { label: 'New', value: 'New'}, {label: 'In Progress', value: 'InProgress'}, {label: 'Closed', value: 'Closed'} ];
    priorityOptions = [ {label: 'All', value: 'All'}, {label: 'Low', value: 'Low'}, {label: 'Medium', value: 'Medium'}, {label: 'High', value: 'High'}, {label: 'Emergency', value: 'Emergency'} ]; 
    categoryOptions = [ {label: 'All', value: 'All'}, {label: 'Plumbing', value: 'Plumbing'}, {label: 'Electrical', value: 'Electrical'}, {label: 'Heating', value: 'Heating'}, {label: 'Appliance', value: 'Appliance'}, {label: 'Other', value: 'Other'}  ];

    @wire(getMaintenanceData, { status: '$status', priority: '$priority', category: '$category', searchKey: '$searchKey' })
    wiredData(result) {
        this.wiredDataResult = result;
        if (result.data) {
            this.counts = result.data.counts;
            this.requests = result.data.requests.map(req => {
               
                let priorityClass = 'priority-badge ';
                if (req.Priority__c === 'Emergency') priorityClass += 'priority-emergency';
                else if (req.Priority__c === 'High') priorityClass += 'priority-high';
                else if (req.Priority__c === 'Medium') priorityClass += 'priority-medium';
                else if (req.Priority__c === 'Low') priorityClass += 'priority-low';

                return {
                    ...req,
                    
                    priorityClass: priorityClass,
                    assetExternalId: req.RentalAsset__r ? req.RentalAsset__r.Id__c : '', 
                    tenantName: req.Tenant__r ? req.Tenant__r.Name : '', 
                    assetName: req.RentalAsset__r ? req.RentalAsset__r.Name : '',
                    isNotNew: req.Status__c !== 'New',
                    isClosed: req.Status__c === 'Closed'
                };
            });
        }
    }

    get kpiData() {
        return [
            { label: 'New', value: this.counts.New, class: 'kpi-card blue' },
            { label: 'In Progress', value: this.counts.InProgress, class: 'kpi-card orange' },
            { label: 'Closed', value: this.counts.Closed, class: 'kpi-card green' }
        ];
    }

    handleFilterChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.detail.value;
    }

    handleSearchClick() {
        const inputVal = this.template.querySelector('.search-input');
        this.searchKey = inputVal.value;
        inputVal.value = '';
    }

    async handleStartWork(event) {
        await updateStatus({ recordId: event.target.dataset.id, newStatus: 'InProgress' });
        return refreshApex(this.wiredDataResult);
    }

    async handleCloseRequest(event) {
        await updateStatus({ recordId: event.target.dataset.id, newStatus: 'Closed' });
        return refreshApex(this.wiredDataResult);
    }

    handleNewRequest() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: { objectApiName: 'MaintenanceRequest__c', actionName: 'new' },
            state: { defaultFieldValues: `RequestedAt__c=${new Date().toISOString()}` }
        });
    }

    navigateToRecord(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: event.target.dataset.id, actionName: 'view' }
        });
    }
}