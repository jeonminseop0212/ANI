//
//  SignUpView.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/24.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import CodableFirebase
import NVActivityIndicatorView

protocol ANISignUpViewDelegate {
  func prifileImagePickButtonTapped()
  func reject(notiText: String)
  func signUpSuccess()
}

class ANISignUpView: UIView {
  
  private weak var scrollView: ANIScrollView?
  private weak var contentView: UIView?
  
  private let CONTENT_SPACE: CGFloat = 25.0
  
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 110.0
  private weak var profileImageView: UIImageView?
  private let PROFILE_IMAGE_PICK_BUTTON_HEIGHT: CGFloat = 30.0
  private weak var profileImagePickButton: ANIImageButtonView?
  
  private weak var adressTitleLabel: UILabel?
  private weak var adressTextFieldBG: UIView?
  private weak var adressTextField: UITextField?
  
  private weak var passwordTitleLabel: UILabel?
  private weak var passwordTextFieldBG: UIView?
  private weak var passwordTextField: UITextField?
  private weak var passwordCheckTextFieldBG: UIView?
  private weak var passwordCheckTextField: UITextField?
  
  private weak var userNameTitleLabel: UILabel?
  private weak var userNameTextFieldBG: UIView?
  private weak var userNameTextField: UITextField?
  
  private let DONE_BUTTON_HEIGHT: CGFloat = 45.0
  private weak var doneButton: ANIAreaButtonView?
  private weak var doneButtonLabel: UILabel?
  
  private var selectedTextFieldMaxY: CGFloat?
  
  private var user: User?
  var profileImage: UIImage? {
    didSet {
      guard let profileImageView = self.profileImageView,
            let profileImage = self.profileImage else { return }
      
      profileImageView.image = profileImage
    }
  }
  
  var delegate: ANISignUpViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
    setupNotification()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //scrollView
    let scrollView = ANIScrollView()
    addSubview(scrollView)
    scrollView.edgesToSuperview()
    self.scrollView = scrollView
    
    //contentView
    let contentView = UIView()
    scrollView.addSubview(contentView)
    contentView.edgesToSuperview()
    contentView.width(to: scrollView)
    self.contentView = contentView
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    contentView.addSubview(profileImageView)
    profileImageView.topToSuperview(offset: 10.0)
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.centerXToSuperview()
    self.profileImageView = profileImageView
    profileImage = UIImage(named: "profileDefaultImage")
    
    //profileImagePickButton
    let profileImagePickButton = ANIImageButtonView()
    profileImagePickButton.image = UIImage(named: "imagePickButton")
    profileImagePickButton.delegate = self
    contentView.addSubview(profileImagePickButton)
    profileImagePickButton.width(PROFILE_IMAGE_PICK_BUTTON_HEIGHT)
    profileImagePickButton.height(PROFILE_IMAGE_PICK_BUTTON_HEIGHT)
    profileImagePickButton.bottom(to: profileImageView)
    profileImagePickButton.right(to: profileImageView)
    self.profileImagePickButton = profileImagePickButton
    
    //adressTitleLabel
    let adressTitleLabel = UILabel()
    adressTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    adressTitleLabel.textColor = ANIColor.dark
    adressTitleLabel.text = "IDを決めましょ！"
    contentView.addSubview(adressTitleLabel)
    adressTitleLabel.topToBottom(of: profileImageView, offset: CONTENT_SPACE)
    adressTitleLabel.leftToSuperview(offset: 10.0)
    adressTitleLabel.rightToSuperview(offset: 10.0)
    self.adressTitleLabel = adressTitleLabel
    
    //adressTextFieldBG
    let adressTextFieldBG = UIView()
    adressTextFieldBG.backgroundColor = ANIColor.lightGray
    adressTextFieldBG.layer.cornerRadius = 10.0
    adressTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(adressTextFieldBG)
    adressTextFieldBG.topToBottom(of: adressTitleLabel, offset: 10.0)
    adressTextFieldBG.leftToSuperview(offset: 10.0)
    adressTextFieldBG.rightToSuperview(offset: 10.0)
    self.adressTextFieldBG = adressTextFieldBG
    
    //adressTextField
    let adressTextField = UITextField()
    adressTextField.font = UIFont.systemFont(ofSize: 18.0)
    adressTextField.textColor = ANIColor.dark
    adressTextField.backgroundColor = .clear
    adressTextField.placeholder = "ex)ANI-ani@ani.com"
    adressTextField.returnKeyType = .done
    adressTextField.keyboardType = .emailAddress
    adressTextField.delegate = self
    adressTextFieldBG.addSubview(adressTextField)
    let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: -10.0)
    adressTextField.edgesToSuperview(insets: insets)
    self.adressTextField = adressTextField
    
    //passwordTitleLabel
    let passwordTitleLabel = UILabel()
    passwordTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    passwordTitleLabel.textColor = ANIColor.dark
    passwordTitleLabel.text = "パスワードを決めましょう🔑"
    contentView.addSubview(passwordTitleLabel)
    passwordTitleLabel.topToBottom(of: adressTextFieldBG, offset: CONTENT_SPACE)
    passwordTitleLabel.leftToSuperview(offset: 10.0)
    passwordTitleLabel.rightToSuperview(offset: 10.0)
    self.passwordTitleLabel = passwordTitleLabel
    
    //passwordTextFieldBG
    let passwordTextFieldBG = UIView()
    passwordTextFieldBG.backgroundColor = ANIColor.lightGray
    passwordTextFieldBG.layer.cornerRadius = 10.0
    passwordTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(passwordTextFieldBG)
    passwordTextFieldBG.topToBottom(of: passwordTitleLabel, offset: 10.0)
    passwordTextFieldBG.leftToSuperview(offset: 10.0)
    passwordTextFieldBG.rightToSuperview(offset: 10.0)
    self.passwordTextFieldBG = passwordTextFieldBG
    
    //passwordTextField
    let passwordTextField = UITextField()
    passwordTextField.font = UIFont.systemFont(ofSize: 18.0)
    passwordTextField.textColor = ANIColor.dark
    passwordTextField.backgroundColor = .clear
    passwordTextField.placeholder = "パスワード"
    passwordTextField.returnKeyType = .done
    passwordTextField.isSecureTextEntry = true
    passwordTextField.delegate = self
    passwordTextFieldBG.addSubview(passwordTextField)
    passwordTextField.edgesToSuperview(insets: insets)
    self.passwordTextField = passwordTextField
    
    //passwordCheckTextFieldBG
    let passwordCheckTextFieldBG = UIView()
    passwordCheckTextFieldBG.backgroundColor = ANIColor.lightGray
    passwordCheckTextFieldBG.layer.cornerRadius = 10.0
    passwordCheckTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(passwordCheckTextFieldBG)
    passwordCheckTextFieldBG.topToBottom(of: passwordTextFieldBG, offset: 10.0)
    passwordCheckTextFieldBG.leftToSuperview(offset: 10.0)
    passwordCheckTextFieldBG.rightToSuperview(offset: 10.0)
    self.passwordCheckTextFieldBG = passwordCheckTextFieldBG
    
    //passwordCheckTextField
    let passwordCheckTextField = UITextField()
    passwordCheckTextField.font = UIFont.systemFont(ofSize: 18.0)
    passwordCheckTextField.textColor = ANIColor.dark
    passwordCheckTextField.backgroundColor = .clear
    passwordCheckTextField.placeholder = "パスワードの確認"
    passwordCheckTextField.returnKeyType = .done
    passwordCheckTextField.isSecureTextEntry = true
    passwordCheckTextField.delegate = self
    passwordCheckTextFieldBG.addSubview(passwordCheckTextField)
    passwordCheckTextField.edgesToSuperview(insets: insets)
    self.passwordCheckTextField = passwordCheckTextField
    
    //userNameTitleLabel
    let userNameTitleLabel = UILabel()
    userNameTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    userNameTitleLabel.textColor = ANIColor.dark
    userNameTitleLabel.text = "ユーザーネームを決めましょ！"
    contentView.addSubview(userNameTitleLabel)
    userNameTitleLabel.topToBottom(of: passwordCheckTextFieldBG, offset: CONTENT_SPACE)
    userNameTitleLabel.leftToSuperview(offset: 10.0)
    userNameTitleLabel.rightToSuperview(offset: 10.0)
    self.userNameTitleLabel = userNameTitleLabel
    
    //userNameTextFieldBG
    let userNameTextFieldBG = UIView()
    userNameTextFieldBG.backgroundColor = ANIColor.lightGray
    userNameTextFieldBG.layer.cornerRadius = 10.0
    userNameTextFieldBG.layer.masksToBounds = true
    contentView.addSubview(userNameTextFieldBG)
    userNameTextFieldBG.topToBottom(of: userNameTitleLabel, offset: 10.0)
    userNameTextFieldBG.leftToSuperview(offset: 10.0)
    userNameTextFieldBG.rightToSuperview(offset: 10.0)
    self.userNameTextFieldBG = userNameTextFieldBG
    
    //userNameTextField
    let userNameTextField = UITextField()
    userNameTextField.font = UIFont.systemFont(ofSize: 18.0)
    userNameTextField.textColor = ANIColor.dark
    userNameTextField.backgroundColor = .clear
    userNameTextField.placeholder = "ex)ANI-ani"
    userNameTextField.returnKeyType = .done
    userNameTextField.delegate = self
    userNameTextFieldBG.addSubview(userNameTextField)
    userNameTextField.edgesToSuperview(insets: insets)
    self.userNameTextField = userNameTextField
    
    //doneButton
    let doneButton = ANIAreaButtonView()
    doneButton.base?.backgroundColor = ANIColor.green
    doneButton.base?.layer.cornerRadius = DONE_BUTTON_HEIGHT / 2
    doneButton.delegate = self
    doneButton.dropShadow(opacity: 0.1)
    contentView.addSubview(doneButton)
    doneButton.topToBottom(of: userNameTextFieldBG, offset: CONTENT_SPACE)
    doneButton.centerXToSuperview()
    doneButton.width(190.0)
    doneButton.height(DONE_BUTTON_HEIGHT)
    doneButton.bottomToSuperview(offset: -10.0)
    self.doneButton = doneButton
    
    //doneButtonLabel
    let doneButtonLabel = UILabel()
    doneButtonLabel.textColor = .white
    doneButtonLabel.text = "OK!"
    doneButtonLabel.textAlignment = .center
    doneButtonLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    doneButton.addContent(doneButtonLabel)
    doneButtonLabel.edgesToSuperview()
    self.doneButtonLabel = doneButtonLabel
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(keyboardWillChangeFrame: self, selector: #selector(keyboardWillChangeFrame))
  }
  
  private func signUp(adress: String, password: String) {
    guard let userNameTextField = self.userNameTextField,
          let userName = userNameTextField.text else { return }
    
    let activityData = ActivityData(size: CGSize(width: 40.0, height: 40.0),type: .lineScale, color: ANIColor.green)
    NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
    
    let database = Firestore.firestore()
    DispatchQueue.global().async {
      database.collection(KEY_USERS).whereField(KEY_USER_NAME, isEqualTo: userName).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        if snapshot.documents.isEmpty {
          self.createAccount(adress: adress, password: password)
        } else {
          NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)

          self.delegate?.reject(notiText: "すでに存在するユーザーネームです！")
        }
      })
    }
  }
  
  private func createAccount(adress: String, password: String) {
    Auth.auth().createUser(withEmail: adress, password: password) { (successUser, error) in
      if let errorUnrap = error {
        let nsError = errorUnrap as NSError
        
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)

        if nsError.code == 17007 {
          self.delegate?.reject(notiText: "すでに存在するメールアドレスです！")
        } else if nsError.code == 17008 {
          self.delegate?.reject(notiText: "メールアドレスの書式が正しくありません！")
        } else if nsError.code == 17026 {
          self.delegate?.reject(notiText: "パスワードが短いです！")
        } else {
          self.delegate?.reject(notiText: "登録に失敗しました！")
        }
      } else {
        self.login(adress: adress, password: password)
      }
    }
  }
  
  private func login(adress: String, password: String) {
    Auth.auth().signIn(withEmail: adress, password: password) { (successUser, error) in
      if let errorUnrap = error {
        print("loginError \(errorUnrap.localizedDescription)")
      } else {
        self.uploadUserData()
      }
    }
  }
  
  private func uploadUserData() {
    guard let currentUser = Auth.auth().currentUser,
          let profileImage = self.profileImage,
          let profileImageData = UIImageJPEGRepresentation(profileImage, 0.5),
          let userNameTextField = self.userNameTextField,
          let userName = userNameTextField.text else { return }

    let storageRef = Storage.storage().reference()
    storageRef.child(KEY_PROFILE_IMAGES).child("\(currentUser.uid).jpeg").putData(profileImageData, metadata: nil) { (metaData, error) in
      if error != nil {
        print("storageError")
        return
      }
      
      if let profileImageUrl = metaData?.downloadURL() {
        let user = FirebaseUser(uid: currentUser.uid, userName: userName, kind: "個人", introduce: "", profileImageUrl: profileImageUrl.absoluteString, familyImageUrls: nil)
        self.uploadUserIntoDatabase(uid: currentUser.uid, user: user)
      }
    }
  }
  
  private func uploadUserIntoDatabase(uid: String, user: FirebaseUser) {
    let database = Firestore.firestore()
    
    do {
      let userData = try FirestoreEncoder().encode(user)
      
      database.collection(KEY_USERS).document(uid).setData(userData) { error in
        if let error = error {
          print("Error set document: \(error)")
          return
        }
        
        self.pushDataAlgolia(data: userData as [String: AnyObject])
        
        ANISessionManager.shared.currentUserUid = Auth.auth().currentUser?.uid
        if let currentUserUid = ANISessionManager.shared.currentUserUid {
          DispatchQueue.global().async {
            database.collection(KEY_USERS).document(currentUserUid).addSnapshotListener({ (snapshot, error) in
              guard let snapshot = snapshot, let value = snapshot.data() else { return }
              
              do {
                let user = try FirestoreDecoder().decode(FirebaseUser.self, from: value)
                
                DispatchQueue.main.async {
                  ANISessionManager.shared.currentUser = user
                  ANISessionManager.shared.isAnonymous = false
                  self.delegate?.signUpSuccess()
                  
                  NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                }
              } catch let error {
                print(error)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
              }
            })
          }
        }
      }
      
      self.endEditing(true)
    } catch let error {
      print(error)
      NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
    }
  }
  
  private func pushDataAlgolia(data: [String: AnyObject]) {
    let index = ANISessionManager.shared.client.index(withName: KEY_USERS_INDEX)
    
    var newData = data
    if let objectId = data[KEY_UID] {
      newData.updateValue(objectId, forKey: KEY_OBJECT_ID)
    }
    
    DispatchQueue.global().async {
      index.addObject(newData, completionHandler: { (content, error) -> Void in
        if error == nil {
          print("Object IDs: \(content!)")
        }
      })
    }
  }
  
  @objc func keyboardWillChangeFrame(_ notification: Notification) {
    guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
          let scrollView = self.scrollView,
          let selectedTextFieldMaxY = self.selectedTextFieldMaxY else { return }
    
    let selectedTextFieldVisiableMaxY = selectedTextFieldMaxY - scrollView.contentOffset.y
    
    if selectedTextFieldVisiableMaxY > keyboardFrame.origin.y {
      let margin: CGFloat = 10.0
      let blindHeight = selectedTextFieldVisiableMaxY - keyboardFrame.origin.y + margin
      scrollView.contentOffset.y = scrollView.contentOffset.y + blindHeight
    }
  }
}

//MARK: ANIButtonViewDelegate
extension ANISignUpView: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view == profileImagePickButton {
      self.delegate?.prifileImagePickButtonTapped()
    }
    if view == doneButton {
      guard let adressTextField = self.adressTextField,
            let adress = adressTextField.text,
            let passwordTextField = self.passwordTextField,
            let password = passwordTextField.text,
            let passwordCheckTextField = self.passwordCheckTextField,
            let passwordCheck = passwordCheckTextField.text,
            let userNameTextField = self.userNameTextField,
            let userName = userNameTextField.text else { return }
      
      if adress.count > 0 && password.count > 0 && passwordCheck.count > 0 && userName.count > 0 {
        if password == passwordCheck {
          signUp(adress: adress, password: password)
        } else {
          self.delegate?.reject(notiText: "パスワードが異なります！")
        }
      } else {
        self.delegate?.reject(notiText: "入力していない項目があります！")
      }
    }
  }
}

//MARK: UITextFieldDelegate
extension ANISignUpView: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    guard let selectedTextViewSuperView = textField.superview else { return }
    selectedTextFieldMaxY = selectedTextViewSuperView.frame.maxY + UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.endEditing(true)
    
    return true
  }
}
