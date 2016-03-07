jest.dontMock("../TypeaheadDropdownMenu.js.jsx");
jest.dontMock("../../TypeaheadItem")

const TypeaheadDropdownMenu = require("../TypeaheadDropdownMenu.js.jsx");

describe("TypeaheadDropdownMenu", () => {
  const React     = require("react/addons");
  const ReactDOM  = require("react-dom");
  const TestUtils = React.addons.TestUtils;

  const renderMenu = (props) => {
    if (!props)       props = {};
    if (!props.query) props.query = "";
    if (!props.activeItemIndex) props.activeItemIndex = 0;
    if (!props.queryMinLength)  props.queryMinLength  = 1;

    return React.createElement(TypeaheadDropdownMenu, props);
  };

  const getMenuAsNode = (props) => {
    return ReactDOM.findDOMNode(
      TestUtils.renderIntoDocument(renderMenu(props))
    );
  };

  describe("when the 'hidden' property", () => {
    describe("is not provided or falsey", () => {
      it("is visible", () => {
        const menu = getMenuAsNode()
        expect(menu.style.display).not.toEqual("none");
      });
    });

    describe("is true", () => {
      it("is hidden", () => {
        const menu = getMenuAsNode({ hidden: true })
        expect(menu.style.display).toEqual("none");
      });
    });
  });

  describe("when passed a list of items", () => {
    it("adds a TypeaheadItem to the list for each item", () => {
      const menu = getMenuAsNode({ items: [
        { name: "Foo" }, { name: "Bar" }, { name: "Buzz" },
      ] });
      expect(menu.childElementCount).toEqual(3);
      expect(menu.children[0].textContent).toEqual("Foo");
      expect(menu.children[1].textContent).toEqual("Bar");
      expect(menu.children[2].textContent).toEqual("Buzz");
    })
  });
});
