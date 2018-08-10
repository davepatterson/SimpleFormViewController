//
//  FormCell.swift
//  ContactsApp
//
//  Created by David Patterson on 8/6/18.
//  Copyright © 2018 David Patterson. All rights reserved.
//

import UIKit

/**
 `FormCell` used to display field in `SimpleFormViewController`
 */
class FormCell: UITableViewCell {
    // UIView used to display view of field.
    var view: UIView? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Method used to set up FormCell.
     */
    func setCell(_ field: UIView) {
        if (field as? UILabel) != nil && field.isUserInteractionEnabled {
            accessoryType = .disclosureIndicator
        }
        
        if view == nil {
            view = field
            addSubview(view!)
        } else {
            view = field
        }
    }

}
