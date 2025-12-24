import { LightningElement, api } from 'lwc';

export default class CarTile extends LightningElement {
	@api car;

	get tileClass() {
		return `tile ${this.car.Rarity__c ? this.car.Rarity__c.toLowerCase() : 'common'}`;
	}

	get rarityClass() {
		return `rarity-badge ${this.car.Rarity__c ? this.car.Rarity__c.toLowerCase() : 'common'}`;
	}

	handleTileClick() {
		const selectEvent = new CustomEvent('carselect', {
			detail: this.car.Id
		});
		this.dispatchEvent(selectEvent);
	}
}
