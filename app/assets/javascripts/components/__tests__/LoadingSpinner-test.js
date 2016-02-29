jest.dontMock("../LoadingSpinner.js.jsx");

const LoadingSpinner = require("../LoadingSpinner.js.jsx");

describe("LoadingSpinner", () => {
  var React          = require('react/addons');
  var TestUtils      = React.addons.TestUtils;
  var LoadingSpinner = require("../LoadingSpinner.js.jsx");

  describe("when the 'hidden' property", () => {
    describe("is not provided", () => {
      it("is visible", () => {
        var node = TestUtils.renderIntoDocument(
          <LoadingSpinner/>
        ).getDOMNode();
        expect(node.style.display).not.toEqual("none");
      });
    });

    describe("is true", () => {
      it("is hidden", () => {
        var node = TestUtils.renderIntoDocument(
          <LoadingSpinner hidden={true}/>
        ).getDOMNode();
        expect(node.style.display).toEqual("none");
      });
    });
  });

});
