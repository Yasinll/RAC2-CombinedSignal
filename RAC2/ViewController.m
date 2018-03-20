//
//  ViewController.m
//  RAC2
//
//  Created by PatrickY on 2017/12/25.
//  Copyright © 2017年 PatrickY. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "Person.h"

@interface ViewController ()
@property (nonatomic) UIButton *btn;

@end

@implementation ViewController {
    
    Person *_person;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self demoBtn];
//    [self demoTextField];
//    [self demoCombineTextField2];
    
    _person = [[Person alloc] init];
    
    _person.name = @"pt";
    _person.age = 18;
    
    [self demoComb];
}

- (void)demoBtn {
    
    _btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    _btn.center = self.view.center;
    
    [self.view addSubview:_btn];
    
    //监听
    [[_btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        NSLog(@"%@",x);
        
    }];
    
}


- (void)demoTextField {
    
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 50, 250, 50)];
    
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.view addSubview:nameTextField];
    
    //监听
    [[nameTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        
        NSLog(@"%@",x);
        
    }];
    
}

- (void)demoCombineTextField {
    
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 50, 250, 50)];
    
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.view addSubview:nameTextField];
    
    UITextField *pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 150, 250, 50)];
    
    pwdTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.view addSubview:pwdTextField];
    
    //监听
    
    [[RACSignal combineLatest:@[nameTextField.rac_textSignal, pwdTextField.rac_textSignal] ] subscribeNext:^(RACTuple * _Nullable x) {
        
//        NSString *name=  x.first;
//        NSString *pwd = x.last;
//        NSLog(@"%@ %@",name, pwd);
        NSLog(@"%@",x);
        
    }];
//    [[nameTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
//
//        NSLog(@"%@",x);
//
//    }];
//
//    [[pwdTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
//
//        NSLog(@"%@",x);
//
//    }];
}


// 注意：在block 中的self.和成员变量 几乎都会循环引用
// 解除循环引用 __weak或者 weakify/strongify
- (void)demoCombineTextField2 {
    
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 150, 250, 50)];
    
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.view addSubview:nameTextField];
    
    UITextField *pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 200, 250, 50)];
    
    pwdTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.view addSubview:pwdTextField];
    
    @weakify(self)
    
    //监听
    /*
    reduce 合并两个信号的数据 ，可以通过接收的参数进行计算，并且返回需要的数值
     id 返回值
    */
    [[RACSignal combineLatest:@[nameTextField.rac_textSignal, pwdTextField.rac_textSignal] reduce:^id (NSString *name, NSString *pwd){
        
        NSLog(@"%@ %@",name, pwd);
        
        // 需求  ：判断用户名和密码是否同时存在 需要转换成NSNumber 才能当做id传递
        return @(name.length > 0 && pwd.length > 0);
        
    }] subscribeNext:^(id  _Nullable x) {
        
        @strongify(self)
        
        self.btn.enabled = [x boolValue];
        
    }];
    
}

// MVVM
- (void)demoComb {
    
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 150, 250, 50)];
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.view addSubview:nameTextField];
    
    UITextField *ageTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 250, 250, 50)];
    ageTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.view addSubview:ageTextField];
    
    //双向绑定
    // 1.模型(KVO 数据)->UI(text 属性)
    RAC(nameTextField, text) = RACObserve(_person, name);
    
    // 基本数据类型 需要使用map 通过block对value 数值进行转换
    RAC(ageTextField, text) = [RACObserve(_person, age) map:^id _Nullable(id  _Nullable value) {
        
        return [value description];
        
    }];
    
    //2.UI到模型
    [[RACSignal combineLatest:@[nameTextField.rac_textSignal, ageTextField.rac_textSignal]] subscribeNext:^(RACTuple * _Nullable x) {
        
        _person.name = [x first];
        _person.age = [[x second] integerValue];
                 
             }];
    
    _btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    _btn.center = self.view.center;
    
    [self.view addSubview:_btn];
    
    [[_btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
    
        NSLog(@"%@ %zd",_person.name, _person.age);
    
    }];
    
    
}

-(void)dealloc {
    
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
