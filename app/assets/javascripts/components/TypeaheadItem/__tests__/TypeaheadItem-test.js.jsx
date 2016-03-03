jest.dontMock("../TypeaheadItem.js.jsx");

const TypeaheadItem = require("../TypeaheadItem.js.jsx");

describe("TypeaheadItem", () => {
  const React     = require("react/addons");
  const ReactDOM  = require("react-dom");
  const TestUtils = React.addons.TestUtils;
  const includes  = (collection, item) => {
    return [].indexOf.call(collection, item) > -1;
  };

  const renderAndFindItem = (props) => {
    if (!props) { props = {} }
    if (!props.query) { props.query = ""; }
    if (!props.text)  { props.text  = ""; }

    const el = TestUtils.renderIntoDocument(
      React.createElement(TypeaheadItem, props)
    );
    return ReactDOM.findDOMNode(el);
  };

  it("is a <li>", () => {
    expect(renderAndFindItem().nodeName).toEqual("LI")
  });

  it("does not have the CSS class 'active'", () => {
    const item = renderAndFindItem()
    expect(includes(item.classList, "active")).toBeFalsy()
  });

  describe("when the prop 'active' is true", () => {
    it("has the CSS class 'active'", () => {
      const item = renderAndFindItem({ active: true })
      expect(includes(item.classList, "active")).toBeTruthy()
    });
  });
});
