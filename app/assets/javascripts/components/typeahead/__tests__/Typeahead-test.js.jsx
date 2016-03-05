// TODO I'm finding I'm basically using 'dontMock' for everything, which
// suggests that I don't actually know how to use Jest mocking properly.
// Figure it out.
jest.dontMock("../Typeahead.js.jsx");
jest.dontMock("../../LoadingSpinner/LoadingSpinner.js.jsx");
jest.dontMock("../../TypeaheadDropdownMenu/TypeaheadDropdownMenu.js.jsx");
jest.dontMock("../../TypeaheadItem/TypeaheadItem.js.jsx");
jest.dontMock("underscore");
jest.dontMock("jquery");

const Typeahead = require("../Typeahead.js.jsx");

describe("Typeahead", () => {
  const React     = require("react/addons");
  const ReactDOM  = require("react-dom");
  const TestUtils = React.addons.TestUtils;
  const $         = require("jquery");
  const _         = require("underscore");

  const getKeyEvent = (key) => {
    const e = { keyIdentifier: key };
    e.keyCode = e.charCode = e.which = {
      "Enter" : 13,
      "Up"    : 38,
      "Down"  : 40,
      // add more keys as we need them.
    }[key];
    return e;
  };

  const inputKeyDown = (key) => {
    TestUtils.Simulate.keyDown(input, getKeyEvent(key));
  };

  const inputKeyPress = (key) => {
    TestUtils.Simulate.keyPress(input, getKeyEvent(key));
  };

  var typeahead, props, menu, input;

  beforeEach(() => {
    if (!props) props = {};

    typeahead = ReactDOM.findDOMNode(
      TestUtils.renderIntoDocument(
        React.createElement(Typeahead, props)
      )
    );
    menu  = typeahead.querySelector(".TypeaheadDropdownMenu");
    input = typeahead.querySelector(".TypeaheadInput");
  });


  const typeQuery = (query) => {
    input.value = query;
    TestUtils.Simulate.change(input);
  };


  describe("typing in a search query", () => {
    describe("that returns no results", () => {
      beforeEach(() => typeQuery("qwertyuio") );

      it("does not show the dropdown menu", () => {
        expect(menu.style.display).toEqual("none");
      });
    });

    describe("that returns some results", () => {
      // TODO currently based on this hardcoded list of sample names:
      // "Dave", "Robert", "Jimmy", "John", "Paul", "Kevin", "Mike", "Sarah",
      // "Susan", "Drew", "Taylor", "Sue", "Claire", "Joanna"
      beforeEach(() => typeQuery("r") );

      it("show them in the dropdown menu", () => {
        expect(menu.style.display).not.toEqual("none");
        // Results:  Robert, Sarah, Drew, Taylor, Claire;
        expect(menu.childElementCount).toEqual(5);
        expect(menu.childElementCount).toEqual(5);
      });

      describe("the first item in the menu", () => {
        it("is highlighted", () => {
          expect(menu.children[0].className).toMatch(/\bactive\b/)
        });
      });

      describe("pressing return", () => {
        it("selects the highlighted (i.e. first) item", () => {
          const firstItem = menu.children[0].textContent;
          inputKeyPress("Enter");
          expect(menu.style.display).toEqual("none");
          expect(input.value).toEqual(firstItem);
        });
      });


      describe("and clicking a result", () => {
        var item;
        beforeEach(() => {
          item = _.find(menu.children, (li) => li.textContent === "Taylor" );
          TestUtils.Simulate.click(item);
          TestUtils.Simulate.click(item);
        });

        it("hides the dropdown", () => {
          expect(menu.style.display).toEqual("none");
        });

        it("populates the text input with the clicked item", () => {
          expect(input.value).toEqual("Taylor");
        });
      });


      describe("and pressing the down arrow key", () => {
        beforeEach(() => inputKeyDown("Down") );

        it("highlights the second item in the list", () => {
          expect(menu.children[1].className).toMatch(/\bactive\b/)
        });

        describe("twice", () => {
          beforeEach(() => inputKeyDown("Down") );

          it("highlights the third item in the list", () => {
            expect(menu.children[2].className).toMatch(/\bactive\b/)
          });
        });
      }); // pressing the down arrow key


      describe("and pressing the up arrow key", () => {
        beforeEach(() => inputKeyDown("Up") );

        it("highlights the last item in the list", () => {
          var noOfItems = menu.children.length;
          expect(menu.children[noOfItems - 1].className).toMatch(/\bactive\b/)
        });

        describe("twice", () => {
          beforeEach(() => inputKeyDown("Up") );

          it("highlights the last but one item in the list", () => {
            var noOfItems = menu.children.length;
            expect(menu.children[noOfItems - 2].className).toMatch(/\bactive\b/)
          });
        });
      }); // pressing the down arrow key
    });
  });
});
