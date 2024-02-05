//
//  CountryCell.swift
//  CountriesChallange
//
//  Created by Madhur on 04/02/24.
//

import UIKit

public final class CountryCell: UITableViewCell {
    
    static let identifier = "CountryCell"
    
    @IBOutlet private(set) public var nameAndRegionLabel: UILabel!
    @IBOutlet private(set) public var capitalLabel: UILabel!
    @IBOutlet private(set) public var countryCodeLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(country: Country) {
        nameAndRegionLabel.text = "\(country.name), \(country.region)"
        countryCodeLabel.text = country.code
        capitalLabel.text = country.capital
    }

}
