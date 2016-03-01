function TypeaheadItem(props) {
  var query = props.query,
      item  = props.text;

  var i = item.toLowerCase().indexOf(query.toLowerCase());
  var len, leftPart, middlePart, rightPart;
  len = query.length;

  if (len === 0){
    els = item;
  } else {
    els = []
    while (i > -1) {
      leftPart   = item.substr(0, i);
      middlePart = item.substr(i, len);
      rightPart  = item.substr(i + len);
      els.push(leftPart);
      els.push(<strong>{middlePart}</strong>);
      item = rightPart;
      i = item.toLowerCase().indexOf(query.toLowerCase());
    }
    els.push(item);
  }

  return (
    <li
      className={props.active ? "active" : ""}
      onMouseEnter={props.onMouseEnter}
      onMouseLeave={props.onMouseLeave}
    >
      <a className="dropdown-item" href="#" role="option">
        {els}
      </a>
    </li>
  );
};

TypeaheadItem.propTypes = {
  active : React.PropTypes.bool.isRequired,
  onMouseEnter : React.PropTypes.func.isRequired,
  onMouseLeave : React.PropTypes.func.isRequired,
  text   : React.PropTypes.string.isRequired,
  query  : React.PropTypes.string.isRequired,
};
