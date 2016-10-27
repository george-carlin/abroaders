import React    from "react";
import ReactDOM from "react-dom";
import $        from "jquery";
import humps    from "humps";

import Button from "../../../core/Button";
import Form   from "../../../core/Form";

const RecommendationNotesForm = React.createClass({
  propTypes: {
    person: React.PropTypes.object.isRequired,
    addRecNoteCallback: React.PropTypes.func.isRequired,
  },

  getInitialState() {
    return {
      actionPath: `/admin/people/${this.props.person.id}/card_recommendations/complete`,
      recommendationNoteContent: "",
    };
  },

  onSubmit(e) {
    e.preventDefault();

    const data = {
      recommendation_note: this.state.recommendationNoteContent,
      authenticity_token: ReactDOM.findDOMNode(this).children[0].value,
    };

    $.post(
      this.state.actionPath,
      data,
      (response) => {
        const recNote = humps.camelizeKeys(response);
        this.props.addRecNoteCallback(recNote);
        this.setState({recommendationNoteContent: ""});
      },
      "json"
    );
  },

  handleChange(e) {
    this.setState({recommendationNoteContent: e.target.value});
  },

  render() {
    return (
      <Form
        className="recommendation-notes-form"
        action={this.state.actionPath}
        method="post"
        onSubmit={this.onSubmit}
      >

        <textarea
          className="form-control"
          rows="3"
          name="recommendation_note"
          placeholder="Recommendation notes (optional)"
          value={this.state.recommendationNoteContent}
          onChange={this.handleChange}
        />

        <Button
          className="submit-btn"
          onClick={this.onSubmit}
          primary
          large
        >
          Done
        </Button>
      </Form>
    );
  },
});

export default RecommendationNotesForm;
