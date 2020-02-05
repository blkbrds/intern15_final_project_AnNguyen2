//
//  FilterViewCustom.swift
//  Movie App
//
//  Created by An Nguyễn on 2/4/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

enum FilterViewActionType {
    case close, didSelectContent
}

protocol FilterViewCustomDelegate: class {
    func closedFilterView(_ view: FilterViewCustom, perform action: FilterViewActionType)
    func filterViewCustom(_ view: FilterViewCustom, didSelectGenre: Genre, perform action: FilterViewActionType)
}

class FilterViewCustom: UIView {
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertContentPickerView: UIPickerView!

    private var genres: [Genre] = []
    weak var delegate: FilterViewCustomDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }

    private func configView() {
        alertContentPickerView.delegate = self
        alertContentPickerView.dataSource = self
    }

    override func draw(_ rect: CGRect) {
        let cornerRadius: CGFloat = 30
        let path = UIBezierPath(roundedRect: self.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    func setupAlertFilterViewCustom(genres: [Genre]) {
        self.genres = genres
        alertContentPickerView.reloadAllComponents()
    }

    @IBAction private func closeAlertButton(_ sender: Any) {
        delegate?.closedFilterView(self, perform: .close)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: -UIPickerViewDelegate
extension FilterViewCustom: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard genres.count > 0 else { return }
        let genre = genres[row]
        delegate?.filterViewCustom(self, didSelectGenre: genre, perform: .didSelectContent)
    }
}

//MARK: -UIPickerViewDataSource
extension FilterViewCustom: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genres.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let genre = genres[row]
        let attributedString: NSAttributedString = NSAttributedString(string: "\(genre.name)", attributes:
                [
                    NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.8),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)
                ])
        return attributedString
    }
}

