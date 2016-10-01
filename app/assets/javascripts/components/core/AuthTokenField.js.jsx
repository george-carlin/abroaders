/* eslint react/no-did-mount-set-state: 0 */
const React = require('react');

const HiddenFieldTag = require("./HiddenFieldTag");

// Rails form tags automatically generate a hidden field called
// 'authenticity_token' that's used to provide CSRF security. Add
// AuthTokenField to your React forms to get the same CSRF protection - else
// Rails will raise an error when you submit the form.
const AuthTokenField = React.createClass({
  getInitialState() {
    return { csrfToken: "" };
  },

  componentDidMount() {
    // Hack to get the csrf-token into the form. `csrf_meta_tags` doesn't
    // output anything in test mode, so only add this hack if the querySelector
    // returns anything:
    const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
    if (csrfMetaTag) {
      this.setState({ csrfToken: csrfMetaTag.content });
    }
  },

  render() {
    return (
      <HiddenFieldTag
        name="authenticity_token"
        value={this.state.csrfToken}
      />
    );
  },
});

module.exports = AuthTokenField;
