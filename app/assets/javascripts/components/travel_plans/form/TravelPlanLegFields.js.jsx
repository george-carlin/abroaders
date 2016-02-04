var TravelPlanLegFields = React.createClass({

  propTypes: {
    index:            React.PropTypes.number.isRequired,
    onRemoveBtnClick: React.PropTypes.func.isRequired,
    showRemoveBtn:    React.PropTypes.bool.isRequired,
  },

  render() {
    var that = this;

    return (
      <div className="travel-leg-form row">

        {
          ["from", "to"].map(function (dest, i) {
            return (
              <DestinationInput
                key={i}
                dest={dest}
                legIndex={that.props.index}
              />
            );
          })
        }


        <div className="col-xs-12 col-sm-2">
          <TravelPlanRemoveLegBtn
            legIndex={this.props.index}
            onClick={this.props.onRemoveBtnClick}
            hidden={!this.props.showRemoveBtn}
          />
        </div>
      </div>
    )
  }
});
