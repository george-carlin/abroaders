var FlightFields = React.createClass({

  propTypes: {
    fromId:           React.PropTypes.number,
    index:            React.PropTypes.number.isRequired,
    onRemoveBtnClick: React.PropTypes.func.isRequired,
    showRemoveBtn:    React.PropTypes.bool.isRequired,
    toId:             React.PropTypes.number,
    onSelectDestination: React.PropTypes.func.isRequired,
  },


  render() {
    var that = this;

    return (
      <div className="FlightFields row">
        {
          ["from", "to"].map(function (dest, i) {
            return (
              <DestinationInput
                key={i}
                dest={dest}
                flightIndex={that.props.index}
                destinationId={that.props[dest + "Id"]}
                onSelect={that.props.onSelectDestination}
              />
            );
          })
        }


        <div className="col-xs-12 col-sm-2">
          <RemoveFlightBtn
            flightIndex={this.props.index}
            onClick={this.props.onRemoveBtnClick}
            hidden={!this.props.showRemoveBtn}
          />
        </div>
      </div>
    )
  }
});
