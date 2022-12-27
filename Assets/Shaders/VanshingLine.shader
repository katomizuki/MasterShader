Shader "Unlit/VanshingLine"
{
    Properties
    {
        _OriginX("PosX Origin", Range(0,1)) = 0.5
        _OriginY("PosY Origin", Range(0, 1)) = 0.5
        _Speed("Speed",  Range(-100, 100)) = 60.0 
        _CircleNbr("Circle quantity", Range(10, 1000)) = 60.0
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            float _OriginX;
            float _OriginY;
            float _Speed;
            float _CircleNbr;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 color;
                float time = _Time.x * _Speed;
                float xdist = _OriginX - i.uv.x;
                float ydist = _OriginY - i.uv.y;
                color = sin(atan2(xdist, ydist) * _CircleNbr + time);
                return color;
            }
            ENDCG
        }
    }
}
