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

  describe("inner text", () => {
    describe("when text does not match query", () => {
      it("does not highlight any text", () => {
        const item = renderAndFindItem({ text: "Wassup", query: "b" });
        const a = item.children[0];
        expect(a.childElementCount).toEqual(1);
        expect(a.children[0].nodeName).toEqual("SPAN");
        expect(a.children[0].textContent).toEqual("Wassup");
      });
    });

    describe("when part of the text matches query", () => {
      it("highlights that part of the text", () => {
        const item = renderAndFindItem({ text: "Wassup", query: "ass" });
        const a = item.children[0];
        expect(a.childElementCount).toEqual(3);
        expect(a.children[0].nodeName).toEqual("SPAN");
        expect(a.children[0].textContent).toEqual("W");
        expect(a.children[1].nodeName).toEqual("STRONG");
        expect(a.children[1].textContent).toEqual("ass");
        expect(a.children[2].nodeName).toEqual("SPAN");
        expect(a.children[2].textContent).toEqual("up");
      });
    });

    describe("when more than one part of the text matches query", () => {
      it("highlights those parts of the text", () => {
        const item = renderAndFindItem({ text: "Hello John", query: "h" });
        const a = item.children[0];
        // An empty span is inserted at the beginning/end if the beginning
        // or end of the text matches the query.
        expect(a.childElementCount).toEqual(5);
        expect(a.children[0].nodeName).toEqual("SPAN");
        expect(a.children[0].textContent).toEqual("");
        expect(a.children[1].nodeName).toEqual("STRONG");
        expect(a.children[1].textContent).toEqual("H");
        expect(a.children[2].nodeName).toEqual("SPAN");
        expect(a.children[2].textContent).toEqual("ello Jo");
        expect(a.children[3].nodeName).toEqual("STRONG");
        expect(a.children[3].textContent).toEqual("h");
        expect(a.children[4].nodeName).toEqual("SPAN");
        expect(a.children[4].textContent).toEqual("n");
      });
    });

    describe("when the entire text matches query", () => {
      it("highlights the entire text", () => {
        const item = renderAndFindItem({ text: "Hello", query: "hello" });
        const a = item.children[0];
        expect(a.childElementCount).toEqual(3);
        expect(a.children[0].nodeName).toEqual("SPAN");
        expect(a.children[0].textContent).toEqual("");
        expect(a.children[1].nodeName).toEqual("STRONG");
        expect(a.children[1].textContent).toEqual("Hello");
        expect(a.children[2].nodeName).toEqual("SPAN");
        expect(a.children[2].textContent).toEqual("");
      });
    });
  });
});
