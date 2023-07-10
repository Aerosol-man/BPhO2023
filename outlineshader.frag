VARYING vec3 pos;

void MAIN()
{
    FRAGCOLOR = vec4(pos.x, pos.y, pos.z, 1.0);
}
