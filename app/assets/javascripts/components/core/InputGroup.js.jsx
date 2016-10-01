const React = require("react");

// A Bootstrap-style input group. See http://getbootstrap.com/components/#input-groups
//
//    <InputGroup
//      addonBefore="$"
//      addonAfter=".00"
//    >
//      <TextFieldTag ... >
//    </InputGroup>
//
//    output:
//    <div class="input-group">
//      <span class="input-group-addon">$</span>
//        <input type="text" class="form-control" ... >
//      <span class="input-group-addon">.00</span>
//    </div>
const addon = (text) => {
  if (text && text.length) {
    return (
      <div className="input-group-addon">
        {text}
      </div>
    );
  }
};

const InputGroup = (_props) => {
  const props       = Object.assign({}, _props);
  const addonAfter  = addon(props.addonAfter);
  const addonBefore = addon(props.addonBefore);
  delete props.addonAfter;
  delete props.addonBefore;

  return (
    <div {...props} className="input-group">
      {addonBefore}
      {props.children}
      {addonAfter}
    </div>
  );
};

InputGroup.propTypes = {
  addonAfter:  React.PropTypes.string,
  addonBefore: React.PropTypes.string,
};

module.exports = InputGroup;
