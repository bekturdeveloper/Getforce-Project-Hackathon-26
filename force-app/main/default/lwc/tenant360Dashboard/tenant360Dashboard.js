import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import searchTenants from '@salesforce/apex/Tenant360Controller.searchTenants';

export default class Tenant360Dashboard extends NavigationMixin(LightningElement) {
    searchKey = '';
    @track tenants = [];
    @track selectedTenant = null;

    isLoading = false;
    attemptedSearch = false;

    columns = [
        { label: 'Tenant Name', fieldName: 'tenantName' },
        { label: 'Email', fieldName: 'email' },
        { label: 'Phone', fieldName: 'phone' },
        { label: 'Status', fieldName: 'status' },
        { label: 'Active Lease Count', fieldName: 'activeLeaseCount', type: 'number' },
        { label: 'Outstanding Amount Total', fieldName: 'outstandingAmountTotal', type: 'currency' },
        { label: 'Last Payment Date', fieldName: 'lastPaymentDate', type: 'date' }
    ];

    get isSearchDisabled() {
        return !this.searchKey || this.searchKey.trim().length < 2 || this.isLoading;
    }

    get showMinCharsHint() {
        return this.searchKey && this.searchKey.trim().length > 0 && this.searchKey.trim().length < 2;
    }

    get hasResults() {
        return this.tenants && this.tenants.length > 0;
    }

    get showNoResults() {
        return this.attemptedSearch && !this.isLoading && (!this.tenants || this.tenants.length === 0);
    }

/* 🔹 Disable Open Tenant Record button when nothing is selected */
get isOpenDisabled() {
    return !this.selectedTenant;
}

    handleInputChange(event) {
        this.searchKey = event.target.value;

        if (!this.searchKey || this.searchKey.trim().length < 2) {
            this.tenants = [];
            this.selectedTenant = null;
            this.attemptedSearch = false;
        }
    }

    async handleSearch() {
        const key = (this.searchKey || '').trim();
        if (key.length < 2) {
            this.tenants = [];
            this.selectedTenant = null;
            this.attemptedSearch = false;
            return;
        }

        this.isLoading = true;
        this.attemptedSearch = true;
        this.selectedTenant = null;

        try {
            const result = await searchTenants({ searchKey: key });
            this.tenants = result || [];
        } catch (e) {
            // eslint-disable-next-line no-console
            console.error('Search error', e);
            this.tenants = [];
        } finally {
            this.isLoading = false;
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedTenant = (selectedRows && selectedRows.length) ? selectedRows[0] : null;
    }

    openTenantRecord() {
        if (!this.selectedTenant?.tenantId) return;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.selectedTenant.tenantId,
                objectApiName: 'Tenant__c',
                actionName: 'view'
            }
        });
    }
}