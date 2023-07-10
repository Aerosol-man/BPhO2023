#include "linesimplify.h"

xt::xarray<double> LineSimplify::vwReduce(xt::xarray<double> points, double epsilon)
{
    /*
    Implementation of the Visvalingham-Whyatt line simplification algorithm
    points - Nx2 array of points
    epsilon - minimum area for each triangle. Controls the level of detail produced
    */
    xt::xarray<double> out = points;
    bool deleted = true;
    int length = points.shape(0);

    while(deleted && length > 3)
    {
        deleted = false;

        //xt::xarray<double> matrices = xt::hstack(xt::xtuple(out, xt::ones<double>({length})));
//        xt::xtensor_fixed<double, xt::xshape<3, 2>> displacements = {0.0, out(0, 0) - out(1, 0), 0.0};

        for (int i = 1; i < length - 1; i++)
        {
            //xt::xtensor_fixed<double, xt::xshape<3, 3>> matrix = xt::view(matrices, xt::range(i - 1, i + 1), xt::all());
//            displacements = {displacements(1), out(i, 0) - out(i + 1, 0), out(i + 1, 0) - out(i - 1, 0)};
//            double area = xt::abs(xt::sum(displacements * xt::index_view(out, {{i - 1, 1}, {i, 1}, {i +1, 1}})));
            double area = std::abs(out(i - 1, 1) * (out(i, 0) - out(i + 1, 0))
                                   + out(i, 1) * (out(i + 1, 0) - out(i - 1, 0))
                                   + out(i + 1, 1) * (out(i, 0) - out(i - 1, 0))) * 0.5;

            if (area < epsilon)
            {
                //deleting points reaaally sucks
//                for (int j = i; j < length - 1; j++)
//                {
//                    out(j, 0) = out(j + 1, 0);
//                    out(j, 1) = out(j + 1, 1);
//                }
                xt::view(out, xt::range(i, length - 2), xt::all()) = xt::view(out, xt::range(i + 1, length - 1), xt::all());
                length--;
                out.resize({length, 2});
                deleted = true;
                break;
            }
        }
    }

    return out;
}
