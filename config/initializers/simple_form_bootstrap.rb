inputs = %w[
  CollectionSelectInput
  DateTimeInput
  FileInput
  GroupedCollectionSelectInput
  NumericInput
  PasswordInput
  RangeInput
  StringInput
  TextInput
]
 
inputs.each do |input_type|
  superclass = "SimpleForm::Inputs::#{input_type}".constantize
 
  new_class = Class.new(superclass) do
    def input_html_classes
      super.push('form-control')
    end
  end
 
  Object.const_set(input_type, new_class)
end
 
# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.boolean_style = :nested
 
  config.wrappers :bootstrap3, tag: 'div', class: 'form-group', error_class: 'has-error',
      defaults: { input_html: { class: 'default_class' } } do |b|
    
    b.use :html5
    b.use :min_max
    b.use :maxlength
    b.use :placeholder
    
    b.optional :pattern
    b.optional :readonly
    
    b.use :label_input
    b.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
  end
  
  config.wrappers :bootstrap3_horizontal, tag: 'div', class: 'form-group', error_class: 'has-error',
      defaults: { input_html: { class: 'default-class '}, wrapper_html: { class: "col-md-9"} } do |b|

    b.use :html5
    b.use :min_max
    b.use :maxlength
    b.use :placeholder

    b.optional :pattern
    b.optional :readonly

    b.use :label_input

    b.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
  end

  config.wrappers :group, tag: 'div', class: "form-group", error_class: 'has-error',
      defaults: { input_html: { class: 'default-class '} }  do |b|

    b.use :html5
    b.use :min_max
    b.use :maxlength
    b.use :placeholder

    b.optional :pattern
    b.optional :readonly

    b.use :label
    b.use :input, wrap_with: { class: "input-group" }
    b.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
  end

  config.wrappers :horizontal, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder

    b.wrapper tag: 'div', class: 'label-hz col-md-2' do |input|
      input.use :label
    end
    
    b.wrapper tag: 'div', class: 'col-md-10' do |input|
      input.use :input
      input.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      input.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.wrappers :inline, :class => 'clearfix', :error_class => :error do |b|
    b.use :placeholder
    b.use :label
    b.use :tag => 'div', :class => 'input' do |ba|
      ba.use :input
      ba.use :error, :tag => :span, :class => :'help-inline'
      ba.use :hint,  :tag => :span, :class => :'help-block'
    end
  end

  config.default_wrapper = :bootstrap3
end