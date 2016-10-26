import React from "react";

const RecommendationNote = (_props) => {
  const props = Object.assign({}, _props);
  const recNote = props.recommendationNote;

  return (
    <div className="row">
      <div className="col-xs-2">
        <b>{recNote.createdAt + ":"}</b>
      </div>

      <div className="col-xs-10">
        {recNote.content}
      </div>
    </div>
  );
};

RecommendationNote.propTypes = Object.assign(
  {
    recommendationNote: React.PropTypes.object.isRequired,
  }
);

export default RecommendationNote;
