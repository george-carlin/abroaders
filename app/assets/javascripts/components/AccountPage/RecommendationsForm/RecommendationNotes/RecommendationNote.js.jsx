import React from "react";

const RecommendationNote = React.createClass({
  propTypes: {
    recommendationNote: React.PropTypes.object.isRequired,
  },

  componentDidMount() {
    this.refs.noteContent.innerHTML = this.props.recommendationNote.content;
  },

  render() {
    return (
      <div className="row">
        <div className="col-xs-2">
          <b>{this.props.recommendationNote.createdAt + ":"}</b>
        </div>

        <div className="col-xs-10 note-content" ref="noteContent"></div>
      </div>
    );
  },
});

export default RecommendationNote;
