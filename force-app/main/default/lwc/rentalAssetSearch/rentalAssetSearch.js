import { LightningElement, track } from 'lwc';
import searchAssets from '@salesforce/apex/RentalAssetSearchController.searchAssets';

export default class RentalAssetSearch extends LightningElement {

    // Filters
    city;
    availability = 'Vacant'; // default
    minBedrooms;
    maxBedrooms;
    maxRent;

    // Results
    @track assets = [];
    showWarning = false;

    // Picklist options
    availabilityOptions = [
        { label: 'Vacant', value: 'Vacant' },
        { label: 'Occupied', value: 'Occupied' }
    ];
    handleAvailabilityChange(event) {
        this.availability = event.detail.value;
    }

    // Table columns
    columns = [
        { label: 'Asset Name', fieldName: 'Name' },
        { label: 'City', fieldName: 'City__c' },
        { label: 'Availability', fieldName: 'AvailabilityStatus__c' },
        { label: 'Bedrooms', fieldName: 'Bedrooms__c', type: 'number' },
        { label: 'Market Rent', fieldName: 'MarketRent__c', type: 'currency' }
    ];

    handleChange(event) {
        this[event.target.label.replace(/\s/g, '').toLowerCase()] =
            event.target.value;
    }

    search() {
        searchAssets({
            city: this.city,
            availability: this.availability,
            minBedrooms: this.minBedrooms,
            maxBedrooms: this.maxBedrooms,
            maxRent: this.maxRent
        })
        .then(result => {
            this.assets = result;
        });
    }

//     handleRowAction(event) {
//         const asset = event.detail.row;

//         // Show warning if occupied
//         this.showWarning = asset.Availability_Status__c === 'Occupied';

//         // Send selected asset to parent wizard
//         this.dispatchEvent(
//         new CustomEvent('assetselected', {
//             detail: {
//                 assetId: asset.Id,
//                 assetName: asset.Name
//     }
// })
//         );
//     }
    handleRowSelection(event) {
    const selectedRows = event.detail.selectedRows;

    if (selectedRows.length > 0) {
        const asset = selectedRows[0];
        
        if (asset.AvailabilityStatus__c === 'Occupied') {
            alert('⚠ Asset is currently occupied.');
        }

        this.dispatchEvent(
            new CustomEvent('assetselected', {
                detail: {
                    assetId: asset.Id,
                    assetName: asset.Name
                }
            })
        );

    }
}
}