import { LightningElement, track, api } from 'lwc';
import searchTenants from '@salesforce/apex/TenantSearchController.searchTenants';

export default class TenantSearch extends LightningElement {

    @track searchKey = '';
    @track tenants = [];

    @api selectedTenantId;

    columns = [
        { label: 'Full Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email__c' },
        { label: 'Phone', fieldName: 'Phone__c' },
        { label: 'Status', fieldName: 'Status__c' }
    ];

    // 🔹 Load tenants on component load
    connectedCallback() {
        this.loadTenants();
    }

    handleChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        this.loadTenants();
    }

    loadTenants() {
        searchTenants({ keyword: this.searchKey })
            .then(result => {
                this.tenants = result;
            })
            .catch(error => {
                console.error('Tenant Search Error:', error);
            });
    }
    handleRowSelection(event) {
    const selectedRows = event.detail.selectedRows;

    if (selectedRows.length > 0) {
        const tenant = selectedRows[0];

        this.dispatchEvent(
            new CustomEvent('tenantselected', {
                detail: {
                    tenantId: tenant.Id,
                    tenantName: tenant.Name
                }
            })
        );
    }
}
}
