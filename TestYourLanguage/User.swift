//
//  User.swift
//  TestYourLanguage
//
//  Created by Ruslan on 4/20/16.
//  Copyright © 2016 Ruslan Palapa. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    dynamic var ID = 0
    let languages = List<Language>()
    dynamic var login = ""
    dynamic var password = ""
    dynamic var profileImage = ""
}

class Language: Object {
    dynamic var owner: User!
    let words = List<Word>()
    let results = List<Result>()
    dynamic var ID = 0
    dynamic var name = ""
}

class Word: Object {
    dynamic var owner: Language!
    dynamic var word = ""
    dynamic var translatedWord = ""
    dynamic var falseAnswerCount = 0
    dynamic var ID = 0
}

class Result: Object {
    dynamic var date = NSDate()
    dynamic var percent = 0
    dynamic var totalQuestion = 0
    dynamic var rightQuestion = 0
}