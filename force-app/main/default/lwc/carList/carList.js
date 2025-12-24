import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCarList from '@salesforce/apex/CarDataController.getCarList';

export default class CarList extends NavigationMixin(LightningElement) {
	@track searchTerm = '';
	@wire(getCarList) cars;

	handleSearch(event) {
		this.searchTerm = event.target.value.toLowerCase();
	}

	get filteredCars() {
		if (!this.cars.data) {
			return [];
		}
		if (!this.searchTerm) {
			return this.cars.data;
		}
		return this.cars.data.filter(car =>
			car.Name.toLowerCase().includes(this.searchTerm) ||
			(car.Class__c && car.Class__c.toLowerCase().includes(this.searchTerm))
		);
	}

	handleCarSelect(event) {
		const carId = event.detail;
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: carId,
				objectApiName: 'Car__c',
				actionName: 'view'
			}
		});
	}
}
