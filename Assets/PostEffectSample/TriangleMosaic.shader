Shader "Unlit/TriangleMosaic"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TileNumX("Tile number x", float) = 0
        _TileNumY("Tile number y", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _TileNumX;
            float _TileNumY;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv / i.uv.w;
                float TileNum = float2(_TileNumX, _TileNumY);
                float2 uv2 = floor(uv * TileNum) / TileNum;
                uv -= uv2;
                uv *= TileNum;
                fixed4 col = tex2D( _MainTex, uv2 + float2(step(1.0 - uv.y, uv.x) / (2.0 * _TileNumX),
                step(uv.x,uv.y)/(2.0 * _TileNumY)));
                return col;
            }
            ENDCG
        }
    }
}
