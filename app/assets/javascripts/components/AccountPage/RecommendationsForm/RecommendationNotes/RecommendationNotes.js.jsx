import React from "react";

import Row                     from "../../../core/Row";
import RecommendationNote      from "./RecommendationNote";
import RecommendationNotesForm from "./RecommendationNotesForm";

const RecommendationNotes = React.createClass({
  propTypes: {
    account: React.PropTypes.object.isRequired,
    person: React.PropTypes.object.isRequired,
  },

  addRecNoteCallback(recNote) {
    this.props.account.recommendationNotes.push(recNote);
    this.setState({newRecNote: recNote});
  },

  render() {
    const account = this.props.account;

    return (
      <Row>
        <div className="col-xs-12 recommendation-notes-area">
          <p>Recommendation Notes</p>
            { account.recommendationNotes.map(recommendationNote => (
            <RecommendationNote
              key={recommendationNote.id}
              recommendationNote={recommendationNote}
            />
          ))}
        </div>

        <div className="col-xs-12">
          <RecommendationNotesForm
            person={this.props.person}
            addRecNoteCallback={this.addRecNoteCallback}
          />
        </div>
      </Row>
    );
  },
});

export default RecommendationNotes;
