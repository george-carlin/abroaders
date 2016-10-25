import classnames from "classnames";

// Example usage:
//
//    cols = {
//      xs:       10,
//      xsOffset: 1,
//      sm:       8,
//      smOffset: 2,
//      md:       6,
//      mdOffset: 3,
//      lg:       4,
//      lgOffset: 4,
//      xl:       2,
//      xlOffset: 5,
//    };
//    columnClassnames(cols);
//    // => "col-xs-12 col-xs-10 col-xs-offset-1 col-sm-8 col-sm-offset-2
//           col-md-6 col-md-offset-3 col-lg-4 col-lg-offset-4 col-xl-2
//           col-xl-offset-5"
//
export default (columns) => {
  const result = {};
  ["xs", "sm", "md", "lg", "xl"].forEach((size) => {
    if (columns[size]) {
      result[`col-${size}-${columns[size]}`] = true;
    }
    const offset = columns[`${size}Offset`];
    if (offset) {
      result[`col-${size}-offset-${offset}`] = true;
    }
  });

  return classnames(result);
};
