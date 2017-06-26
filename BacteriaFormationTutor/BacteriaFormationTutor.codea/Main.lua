-- Bacteria Formation Tutor
displayMode(FULLSCREEN_NO_BUTTONS)
-- Use this function to perform your initial setup
function setup()
    rectMode(CENTER)
    debugDraw = PhysicsDebugDraw()
    ellipseMode(CENTER)
    xw = WIDTH/1024
    if WIDTH > 1.5*HEIGHT then
        xw = xw*0.6
    end
    pronounciation = {}
    if xw >= 1 then
        xw = 0.8
    end
    if HEIGHT/WIDTH < xw then
        xw = HEIGHT/WIDTH*0.8
    end
    cBody = 0
    touchMap = {}
    label = ""
    tutorial = false
    choices = {"diplococci","diplobacilli","streptococci","streptobacilli","staphylococci","staphylobacilli","tetrad","sarcina"}
    --1: Is it in quiz screen, 2: is quizzing
    quiz = {false,false}
    displayQuiz = 0
    phase = 0
    hint = 0
    pop=.9
end

function orientationChanged( newOrientation )
    xw = WIDTH/1024
    if WIDTH > 1.5*HEIGHT then
        xw = xw*0.6
    end
end

function choiceCheck(input)
    output = (input == label)
    if #quiz > 3 and output == false then
        for j=3,#quiz do
            if quiz[j] == input then
                output = true
            end
        end
    end
    return output
end

-- This function gets called once every frame
function draw()
    if pop < 1 then
        pop = pop + .01
    end
    -- This sets a dark background color
    background(255, 255, 255, 255)
    fill(0)
    if tutorial then
        if CurrentOrientation == PORTRAIT or CurrentOrientation == PORTRAIT_UPSIDE_DOWN then
        sprite("Project:tutorial",WIDTH/2,HEIGHT/2,WIDTH)
        else
        sprite("Project:tutorial",WIDTH/2,HEIGHT/2,HEIGHT*3.5/4)
        end
        sprite("Project:back",WIDTH/16,HEIGHT*7/8,100*xw)
    elseif quiz[1] and displayQuiz > 220 and phase == 0 then
        if quiz[3] == nil then
            for i=3,6 do
                temp = math.random(1,#choices)
                while choiceCheck(choices[temp]) do
                    temp = math.random(1,#choices)
                end
                quiz[i] = choices[temp]
            end
            quiz[math.random(3,6)] = label
        end
        debugDraw:draw()
        fontSize(70*xw)
        text("What is this formation?",WIDTH/2,HEIGHT*7/8)
        for i=3,6 do
            --tint(255)
            fill(0,90,255,125)
            strokeWidth(0)
            rect(WIDTH/2,HEIGHT*7.3/8-(i-2)*HEIGHT/5,WIDTH*7/8,HEIGHT/6)
            fill(0)
            --sprite("Project:box",WIDTH/2,HEIGHT*7/8-(i-2)*HEIGHT/5,WIDTH*7/8,HEIGHT/6)
            text(quiz[i],WIDTH/2,HEIGHT*7.3/8-(i-2)*HEIGHT/5)
        end
    else
        if quiz[1] and phase == 0 then
            displayQuiz = displayQuiz + 1
        else
        displayQuiz = 0
        end
        debugDraw:draw()
        spriteMode(CENTER)
        sprite("Project:coc",WIDTH/4,HEIGHT/8,100*xw)
        -- ellipse(WIDTH/4,HEIGHT/8,100*xw)
        sprite("Project:bac",WIDTH/2,HEIGHT/8,100*xw,200*xw)
        --ellipse(WIDTH*3/4,HEIGHT/8,100*xw,200*xw)
        fontSize(40*xw)
        fill(255)
        --sprite("Project:button",WIDTH*4/5,HEIGHT/8,280*xw,120*xw)
        -- sprite("Project:button",WIDTH*2/5,HEIGHT/8,200*xw,120*xw)
       -- text("RESET",WIDTH*2/5,HEIGHT/8)
       -- if quiz[2] then
            --fill(0,255,0,255)

            --text("Quiz Mode On",WIDTH*4/5,HEIGHT/8)
       -- else
            --fill(255,0,0,255)
            --text("Quiz Mode Off",WIDTH*4/5,HEIGHT/8)
       -- end
        --text("?",WIDTH*4/5,HEIGHT/8)
        sprite("Project:bars",WIDTH/4*3,HEIGHT/8,100*xw)
        fill(0)
        fontSize(120*xw)
        if quiz[1] == false then
        text(label, WIDTH/2,HEIGHT/3.6)
        elseif displayQuiz > 225 then

        end
        if phase > 0 then
            tint(255,255,255,255*pop)
            if CurrentOrientation == PORTRAIT or CurrentOrientation == PORTRAIT_UPSIDE_DOWN then
                sprite("Project:menu"..phase,WIDTH/2,HEIGHT/4*2.25,WIDTH*3/4*pop)
            else
                sprite("Project:menu"..phase,WIDTH/2,HEIGHT/4*2.25,HEIGHT*3/4*pop)
            end
            tint(255)
        end
        if CurrentTouch.state == ENDED then
            detection()
            tutorial = false
        end
        
        fontSize(40*xw)
       -- text("tap and hold here for more information",WIDTH/2,HEIGHT*7/8)
        -- print(#debugDraw.joints)
        
        
        -- This sets the line thickness
        strokeWidth(5)
        
    end
    -- Do your drawing here
    
end

function detection()
    --for t, joint in ipairs(debugDraw.joints) do
    temp2 = label
    if #debugDraw.joints == 1 then
        if label ~= "diplo"..debugDraw.joints[#debugDraw.joints].bodyA.info then
            label = "diplo"..debugDraw.joints[#debugDraw.joints].bodyA.info
            if quiz[2] then
                quiz[1] = true
            end
            if debugDraw.joints[#debugDraw.joints].bodyA.info == "cocci" then
                pronounciation[label] = "dip low cox eye"
            else
                pronounciation[label] = ("dip low bass sill eye")
            end
            
        end
    elseif strepCheck() then
        if label ~="strepto"..debugDraw.joints[#debugDraw.joints].bodyA.info then
            label ="strepto"..debugDraw.joints[#debugDraw.joints].bodyA.info
            if quiz[2] then
                quiz[1] = true
            end
            if debugDraw.joints[#debugDraw.joints].bodyA.info == "cocci" then
                pronounciation[label] = ("strehp toe cox eye")
            else
                pronounciation[label] = ("strep toe bass sill eye")
            end
            
        end
    elseif staphCheck() or staphCheckOld() then
        if label ~="staphylo"..debugDraw.joints[#debugDraw.joints].bodyA.info then
            label ="staphylo"..debugDraw.joints[#debugDraw.joints].bodyA.info
            if quiz[2] then
                quiz[1] = true
            end
            if debugDraw.joints[#debugDraw.joints].bodyA.info == "cocci" then
                pronounciation[label] = ("staff ill low cox eye")
            else
                pronounciation[label] = ("staff ill low bass sill eye")
            end
            
        end
    elseif tetCheck() then
        if label ~= "tetrad" then
            label = "tetrad"
            if quiz[2] then
                quiz[1] = true
            end
            pronounciation[label] = ("teh trahd")
            

        end
  --  elseif sarCheck() then
    --    if label ~= "sarcina" then
       --     label = "sarcina"
          --  if quiz[2] then
            --    quiz[1] = true
         --   end
           -- pronounciation[label] = ("sahr sih knee")
            
       -- end
    else
        label = ""
    end
    if temp2 ~= label and label ~= "" and quiz[2] == false and speech.speaking == false then
        --  print(pronounciation[label])
        speech.say(pronounciation[label])
    end
    --  end
end

function sarCheck()
    if  #debugDraw.bodies == 8 then
        output = true
        for i = 1,#debugDraw.joints do
            if debugDraw.joints[i].bodyA.info ~= "cocci" or debugDraw.joints[i].bodyB.info ~= "cocci" then
                output = false
            end
        end
        collisionCounter = collisions()
        --  collisionCounter = mapCount(collisionCounter)
        --if  then
       -- return output and zeroCount(collisionCounter) == 0
    else
       -- return false
    end
end

function tetCheck()
    if #debugDraw.joints == 4 then
        return #debugDraw.bodies == 4 and debugDraw.joints[1].bodyA.info == "cocci"
    else
        return false
    end
    --  collisionCounter = collisions()
    --collisionCounter = mapCount(collisionCounter)
    --  if collisionCounter[]
    -- end
end

function staphCheck()
   b = 3
    j = 3
    output = false
    while b <= 10 do
        if b==#debugDraw.bodies and j==#debugDraw.joints then
            output = true
            break
        end
        b = b + 1
        j = j + 2
        if b > 7 then
            j = j + 1
        end
    end
    return output
end

function staphCheckOld()
    if #debugDraw.joints ~= 18 then
        return false
        
    else
        collisionCounter = collisions()
        collisionCounter = mapCount(collisionCounter)
        -- print(collisionCounter[1])
        --print(collisionCounter[5])
        return (collisionCounter[1] == nil and collisionCounter[2] == 3 and collisionCounter[3] == nil and collisionCounter[4] == 6  and collisionCounter[6] == 1)
    end
end

function mapCount(collisions)
    output = {}
    for i = 1, #debugDraw.bodies do
        if collisions[i] ~= nil then
            if output[collisions[i]] ~= nil then
                output[collisions[i]] = output[collisions[i]] + 1
            else
                output[collisions[i]] = 1
            end
        end
    end
    return output
end

function zeroCount(collisions)
    output = 0
    for i = 1, #debugDraw.bodies do
        if collisions[i] == nil then
            output = output+1
        end
    end
    return output
end

function collisions()
    collisionCounter = {}
    
    for i,joint in ipairs(debugDraw.joints) do
        for b,body in ipairs(debugDraw.bodies) do
            if body == joint.bodyA or body == joint.bodyB then
                if collisionCounter[b] == nil then
                    collisionCounter[b] = 1
                else
                    collisionCounter[b] = collisionCounter[b] + 1
                end
            end
        end
    end
    return collisionCounter
end

function strepCheck()
    if #debugDraw.joints < 2 or #debugDraw.bodies < 6 then
        return false
    else
        collisionCounter = collisions()
        flag = true
        one = 0
        two = 0
        for i = 1, #debugDraw.bodies do
            if collisionCounter[i] == 1 then
                
                one = one + 1
            elseif collisionCounter[i] == 2 then
                two = two + 1
            else
                flag = false
            end
        end
        -- print(one)
        if one ~= 2 then
            flag = false
        end
        return flag
    end
end


function touched(touch)
    if tutorial then
        if touch.state == BEGAN and touch.y > HEIGHT*7/8-50*xw and touch.x < HEIGHT/8+50*xw then
            tutorial = false
        end
    elseif phase == 0 then
    if quiz[1] and displayQuiz > 220 then
        if touch.state == BEGAN then
            for i=3,6 do
                if touch.y > HEIGHT*7.3/8-(i-2)*HEIGHT/5-HEIGHT/12 and touch.y < HEIGHT*7.3/8-(i-2)*HEIGHT/5+HEIGHT/12 then
                    if quiz[i] == label then
                        speech.say("correct!")
                        speech.say(pronounciation[label])
                        quiz = {false,true}
                    else
                        speech.say("try again")
                    end
                end
            end
        end
    else
        flag = false
        if touch.state == BEGAN then
            if touch.y > HEIGHT/8-100*xw and touch.y < HEIGHT/8+100*xw then
                if touch.x > WIDTH/4-100*xw and touch.x < WIDTH/4+100*xw  then
                    createCircle(WIDTH/4,HEIGHT/8,100*xw,"cocci")
                    touchMap[touch.id] = cBody
                    quiz[1] = false
                --elseif touch.x > WIDTH*2/5-100*xw and touch.x < WIDTH/5*2+100*xw then
                 --   debugDraw:clear()
                  --  touchMap = {}
                elseif touch.x > WIDTH/2-100*xw and touch.x < WIDTH/2+100*xw then
                    createBox(WIDTH/2,HEIGHT/8,100*xw,200*xw,"bacilli")
                    touchMap[touch.id] = cBody
                    quiz[1] = false
                elseif touch.x > WIDTH/4*3-100*xw and touch.x < WIDTH/4*3+100*xw then
                    pop = 0.9
                    if quiz[2] then phase = 2 else phase = 1 end

                end
            elseif touch.y > HEIGHT/8*7-40*xw then
                tutorial = true
            end
            detectTouch(touch)
        elseif touch.state == ENDED and tutorial then
            tutorial = false
        end
        
        
        if touch.state == ENDED then
            touchMap[touch.id] = nil
        elseif touchMap[touch.id] ~= nil then
            debugDraw.bodies[touchMap[touch.id]].x = touch.x
            debugDraw.bodies[touchMap[touch.id]].y = touch.y
        end
    end
    elseif phase == 1 or phase == 2 then
        if touch.state == BEGAN then
        if CurrentOrientation == PORTRAIT or CurrentOrientation == PORTRAIT_UPSIDE_DOWN then
            constant = WIDTH
        else
            constant = HEIGHT
        end
        if touch.x > WIDTH/8 and touch.x < WIDTH*7/8 then
        if touch.y > HEIGHT/4*2.25+constant*3/4/269*(0-297/2) and touch.y < HEIGHT/4*2.25+constant*3/4/269*(42-297/2) then
            phase = 0
        elseif touch.y > HEIGHT/4*2.25+constant*3/4/269*(42-297/2) and touch.y < HEIGHT/4*2.25+constant*3/4/269*(88-297/2) then
        tutorial = true
        phase = 0
        elseif touch.y > HEIGHT/4*2.25+constant*3/4/269*(88-297/2) and touch.y < HEIGHT/4*2.25+constant*3/4/269*(132-297/2) then
        phase = 3
        pop=0.9
        elseif touch.y > HEIGHT/4*2.25+constant*3/4/269*(132-297/2) and touch.y < HEIGHT/4*2.25+constant*3/4/269*(175-297/2) then
            quiz[2] = (quiz[2] == false)
            phase = 0
        elseif touch.y > HEIGHT/4*2.25+constant*3/4/269*(175-297/2) and touch.y < HEIGHT/4*2.25+constant*3/4/269*(219-297/2) then
            debugDraw:clear()
            touchMap = {}
            phase = 0
        elseif touch.y > HEIGHT/4*2.25+constant*3/4/269*(297-297/2) or touch.y < HEIGHT/4*2.25+constant*3/4/269*(0-297/2) then
            phase = 0
        end
        else
            phase = 0
        end
    end
    elseif phase == 3 then

    end
end

function detectTouch(touch)
    if phase == 0 then
    for i,body in ipairs(debugDraw.bodies) do
        if touch.x > body.x-100*xw and touch.x < body.x+100*xw and touch.y > body.y-100*xw and touch.y < body.y+100*xw then
            touchMap[touch.id] = i
            break
        end
    end
    end
end

function createCircle(x,y,r,info)
    label = ""
    local circle = physics.body(CIRCLE, r/2)
    -- enable smooth motion
    circle.interpolate = true
    circle.x = x
    circle.y = y
    circle.restitution = 0
    circle.friction = 0.4
    circle.gravityScale = 0
    circle.sleepingAllowed = false
    circle.info = info
    debugDraw:addBody(circle)
    cBody = #debugDraw.bodies
    
    return circle
end

function createBox(x,y,w,h,info)
    label = ""
    -- polygons are defined by a series of points in counter-clockwise order
    local box = physics.body(POLYGON, vec2(-w/2,h/2), vec2(-w/2,-h/2), vec2(w/2,-h/2), vec2(w/2,h/2))
    box.interpolate = true
    box.x = x
    box.y = y
    box.restitutions = 0
    box.friction = 0.4
    box.gravityScale = 0
    box.sleepingAllowed = false
    box.info = info
    debugDraw:addBody(box)
    cBody = #debugDraw.bodies
    return box
end

function collide(contact)
    if debugDraw then
        debugDraw:collide(contact)
    end
end
