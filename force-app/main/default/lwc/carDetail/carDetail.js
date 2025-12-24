import { LightningElement, api, wire } from 'lwc';
import getCarDetail from '@salesforce/apex/CarDataController.getCarDetail';

const COLUMNS = [
	{ label: 'Star', fieldName: 'Star_Level__c', type: 'number', cellAttributes: { alignment: 'center' } },
	{ label: 'BPs', fieldName: 'Blueprints_Required__c', type: 'number' },
	{ label: 'Rank Min', fieldName: 'Rank_Min__c', type: 'number' },
	{ label: 'Rank Max', fieldName: 'Rank_Max__c', type: 'number' },
	{ label: 'Top Speed', fieldName: 'Top_Speed_Max__c', type: 'number', typeAttributes: { maximumFractionDigits: 2 } },
	{ label: 'Accel', fieldName: 'Accel_Max__c', type: 'number', typeAttributes: { maximumFractionDigits: 2 } },
	{ label: 'Handling', fieldName: 'Handling_Max__c', type: 'number', typeAttributes: { maximumFractionDigits: 2 } },
	{ label: 'Nitro', fieldName: 'Nitro_Max__c', type: 'number', typeAttributes: { maximumFractionDigits: 2 } }
];

export default class CarDetail extends LightningElement {
	@api recordId;
	columns = COLUMNS;

	@wire(getCarDetail, { carId: '$recordId' })
	car;

	get starLevels() {
		if (this.car.data && this.car.data.Car_Star_Levels__r) {
			return this.car.data.Car_Star_Levels__r;
		}
		return null;
	}

	get errorMessage() {
		if (this.car.error) {
			return JSON.stringify(this.car.error);
		}
		return '';
	}
}
