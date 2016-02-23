function FlightFields(props) {
  return (
    <div className="FlightFields row">
      {
        ["from", "to"].map(function (dest, i) {
          return (
            <DestinationInput
              key={i}
              dest={dest}
              flightIndex={props.index}
              destinationId={props[dest + "Id"]}
              onSelect={props.onSelectDestination}
            />
          );
        })
      }


      <div className="col-xs-12 col-sm-2">
        <RemoveFlightBtn
          flightIndex={props.index}
          hidden={!props.showRemoveBtn}
          onClick={props.onRemoveBtnClick}
        />
      </div>
    </div>
  )
};

FlightFields.propTypes = {
  fromId:              React.PropTypes.number,
  index:               React.PropTypes.number.isRequired,
  onRemoveBtnClick:    React.PropTypes.func.isRequired,
  onSelectDestination: React.PropTypes.func.isRequired,
  showRemoveBtn:       React.PropTypes.bool.isRequired,
  toId:                React.PropTypes.number,
};
